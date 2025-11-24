//
//  CameraService.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import AVFoundation
import UIKit
import SwiftUI

// MARK: - Camera Service
@MainActor
final class CameraService: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var capturedImage: UIImage?
    @Published var error: CameraError?
    @Published var isCapturing = false

    // Camera session
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentDevice: AVCaptureDevice?
    private var deviceInput: AVCaptureDeviceInput?

    // Camera position
    @Published var position: AVCaptureDevice.Position = .back

    // Flash
    @Published var flashMode: AVCaptureDevice.FlashMode = .auto

    private var photoContinuation: CheckedContinuation<UIImage?, Error>?

    override init() {
        super.init()
    }

    // MARK: - Authorization

    func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            isAuthorized = granted
            return granted
        case .denied, .restricted:
            isAuthorized = false
            return false
        @unknown default:
            isAuthorized = false
            return false
        }
    }

    // MARK: - Session Setup

    func setupSession() async throws {
        guard await checkAuthorization() else {
            throw CameraError.notAuthorized
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        // Setup device
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            throw CameraError.deviceNotFound
        }

        currentDevice = device

        // Setup input
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                deviceInput = input
            } else {
                throw CameraError.cannotAddInput
            }
        } catch {
            throw CameraError.inputError(error)
        }

        // Setup output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .quality
        } else {
            throw CameraError.cannotAddOutput
        }

        session.commitConfiguration()
    }

    func startSession() {
        guard !session.isRunning else { return }
        Task.detached(priority: .userInitiated) {
            await MainActor.run {
                self.session.startRunning()
            }
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    // MARK: - Camera Controls

    func switchCamera() async throws {
        position = (position == .back) ? .front : .back

        session.beginConfiguration()

        // Remove current input
        if let currentInput = deviceInput {
            session.removeInput(currentInput)
        }

        // Add new input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            throw CameraError.deviceNotFound
        }

        currentDevice = device

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                deviceInput = input
            } else {
                throw CameraError.cannotAddInput
            }
        } catch {
            throw CameraError.inputError(error)
        }

        session.commitConfiguration()
    }

    func toggleFlash() {
        switch flashMode {
        case .auto:
            flashMode = .on
        case .on:
            flashMode = .off
        case .off:
            flashMode = .auto
        @unknown default:
            flashMode = .auto
        }
    }

    func setFocus(at point: CGPoint, in previewLayerFrame: CGRect) {
        guard let device = currentDevice else { return }

        let focusPoint = CGPoint(
            x: point.y / previewLayerFrame.height,
            y: 1.0 - point.x / previewLayerFrame.width
        )

        do {
            try device.lockForConfiguration()

            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }

            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }

            device.unlockForConfiguration()
        } catch {
            print("Error setting focus: \(error)")
        }
    }

    // MARK: - Capture Photo

    func capturePhoto() async throws -> UIImage? {
        guard !isCapturing else { return nil }

        isCapturing = true
        defer { isCapturing = false }

        HapticManager.shared.buttonTap()

        return try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation

            let settings = AVCapturePhotoSettings()

            // Flash settings
            if photoOutput.supportedFlashModes.contains(flashMode) {
                settings.flashMode = flashMode
            }

            // Quality settings
            settings.maxPhotoDimensions = photoOutput.maxPhotoDimensions

            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        Task { @MainActor in
            if let error = error {
                photoContinuation?.resume(throwing: CameraError.captureError(error))
                photoContinuation = nil
                return
            }

            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                photoContinuation?.resume(throwing: CameraError.imageProcessingFailed)
                photoContinuation = nil
                return
            }

            // Fix orientation if using front camera
            let correctedImage: UIImage
            if position == .front {
                correctedImage = image.withHorizontallyFlippedOrientation()
            } else {
                correctedImage = image
            }

            capturedImage = correctedImage
            HapticManager.shared.success()

            photoContinuation?.resume(returning: correctedImage)
            photoContinuation = nil
        }
    }
}

// MARK: - Camera Error
enum CameraError: LocalizedError {
    case notAuthorized
    case deviceNotFound
    case cannotAddInput
    case cannotAddOutput
    case inputError(Error)
    case captureError(Error)
    case imageProcessingFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Acesso à câmera não autorizado"
        case .deviceNotFound:
            return "Câmera não encontrada"
        case .cannotAddInput:
            return "Não foi possível configurar a entrada da câmera"
        case .cannotAddOutput:
            return "Não foi possível configurar a saída da câmera"
        case .inputError(let error):
            return "Erro de entrada: \(error.localizedDescription)"
        case .captureError(let error):
            return "Erro ao capturar: \(error.localizedDescription)"
        case .imageProcessingFailed:
            return "Falha ao processar imagem"
        }
    }
}

// MARK: - Camera Preview View (UIViewRepresentable)
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func withHorizontallyFlippedOrientation() -> UIImage {
        guard let cgImage = self.cgImage else { return self }

        let flippedOrientation: UIImage.Orientation
        switch imageOrientation {
        case .up: flippedOrientation = .upMirrored
        case .down: flippedOrientation = .downMirrored
        case .left: flippedOrientation = .leftMirrored
        case .right: flippedOrientation = .rightMirrored
        case .upMirrored: flippedOrientation = .up
        case .downMirrored: flippedOrientation = .down
        case .leftMirrored: flippedOrientation = .left
        case .rightMirrored: flippedOrientation = .right
        @unknown default: flippedOrientation = .up
        }

        return UIImage(cgImage: cgImage, scale: scale, orientation: flippedOrientation)
    }
}

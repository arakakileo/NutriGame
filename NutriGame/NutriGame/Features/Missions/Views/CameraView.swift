//
//  CameraView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI
import PhotosUI

struct CameraView: View {
    let missionType: MissionType
    let onPhotoTaken: (Data) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingConfirmation = false
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                if let image = selectedImage {
                    // Preview da foto
                    PhotoConfirmationView(
                        image: image,
                        missionType: missionType,
                        onConfirm: {
                            if let data = image.jpegData(compressionQuality: 0.8) {
                                onPhotoTaken(data)
                                dismiss()
                            }
                        },
                        onRetake: {
                            selectedImage = nil
                        }
                    )
                } else {
                    // Opções de captura
                    CaptureOptionsView(
                        missionType: missionType,
                        onCameraSelected: {
                            sourceType = .camera
                            showingImagePicker = true
                        },
                        onGallerySelected: {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        }
                    )
                }
            }
            .navigationTitle(missionType.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: sourceType)
            }
        }
    }
}

// MARK: - Capture Options View
struct CaptureOptionsView: View {
    let missionType: MissionType
    let onCameraSelected: () -> Void
    let onGallerySelected: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.forMission(missionType).opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: missionType.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Color.forMission(missionType))
            }

            // Instructions
            VStack(spacing: Spacing.sm) {
                Text("Registre seu \(missionType.displayName.lowercased())")
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)

                Text("Tire uma foto para ganhar +\(missionType.xpReward) XP")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Buttons
            VStack(spacing: Spacing.md) {
                Button(action: onCameraSelected) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Tirar Foto")
                    }
                    .primaryButtonStyle()
                }

                Button(action: onGallerySelected) {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("Escolher da Galeria")
                    }
                    .secondaryButtonStyle()
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xxl)
        }
    }
}

// MARK: - Photo Confirmation View
struct PhotoConfirmationView: View {
    let image: UIImage
    let missionType: MissionType
    let onConfirm: () -> Void
    let onRetake: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Image preview
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(CornerRadius.large)
                .padding(.horizontal, Spacing.md)

            // XP badge
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.accentGreen)
                Text("+\(missionType.xpReward) XP")
                    .font(.xpMedium)
                    .foregroundColor(.accentGreen)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(Color.accentGreen.opacity(0.1))
            .cornerRadius(CornerRadius.full)

            Spacer()

            // Buttons
            VStack(spacing: Spacing.md) {
                Button(action: onConfirm) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Confirmar")
                    }
                    .primaryButtonStyle()
                }

                Button(action: onRetake) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Tirar Outra")
                    }
                    .secondaryButtonStyle()
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xxl)
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CameraView(missionType: .breakfast) { _ in }
}

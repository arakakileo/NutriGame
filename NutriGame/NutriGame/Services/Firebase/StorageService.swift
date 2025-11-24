//
//  StorageService.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import UIKit

final class StorageService {
    static let shared = StorageService()

    private let firebase = FirebaseService.shared

    private init() {}

    // MARK: - Avatar Upload

    /// Faz upload do avatar do usuário
    func uploadAvatar(userId: String, image: UIImage) async throws -> URL {
        let imageData = try compressImage(image)
        let ref = firebase.avatarRef(userId: userId)
        return try await firebase.uploadImage(imageData, to: ref)
    }

    /// Deleta o avatar do usuário
    func deleteAvatar(userId: String) async throws {
        let ref = firebase.avatarRef(userId: userId)
        try await firebase.deleteImage(at: ref)
    }

    // MARK: - Mission Photo Upload

    /// Faz upload de foto de missão
    func uploadMissionPhoto(missionId: String, image: UIImage) async throws -> URL {
        let imageData = try compressImage(image)
        let ref = firebase.missionPhotoRef(missionId: missionId)
        return try await firebase.uploadImage(imageData, to: ref)
    }

    /// Deleta foto de missão
    func deleteMissionPhoto(missionId: String) async throws {
        let ref = firebase.missionPhotoRef(missionId: missionId)
        try await firebase.deleteImage(at: ref)
    }

    // MARK: - Image Compression

    /// Comprime e redimensiona a imagem
    func compressImage(_ image: UIImage) throws -> Data {
        // Redimensiona se necessário
        let resized = resizeImage(image, maxDimension: Constants.Image.maxDimension)

        // Comprime para JPEG
        guard let data = resized.jpegData(compressionQuality: Constants.Image.compressionQuality) else {
            throw StorageError.compressionFailed
        }

        // Verifica tamanho
        if data.count > Constants.Image.maxFileSizeBytes {
            // Tenta comprimir mais
            var quality = Constants.Image.compressionQuality - 0.1
            var compressedData = data

            while compressedData.count > Constants.Image.maxFileSizeBytes && quality > 0.1 {
                if let newData = resized.jpegData(compressionQuality: quality) {
                    compressedData = newData
                }
                quality -= 0.1
            }

            return compressedData
        }

        return data
    }

    /// Redimensiona a imagem mantendo proporção
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSize = max(size.width, size.height)

        guard maxSize > maxDimension else {
            return image
        }

        let scale = maxDimension / maxSize
        let newWidth = size.width * scale
        let newHeight = size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized ?? image
    }
}

// MARK: - Errors
enum StorageError: LocalizedError {
    case compressionFailed
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Falha ao processar a imagem."
        case .uploadFailed:
            return "Falha ao enviar a imagem."
        case .downloadFailed:
            return "Falha ao baixar a imagem."
        case .deleteFailed:
            return "Falha ao deletar a imagem."
        case .invalidImage:
            return "Imagem inválida."
        }
    }
}

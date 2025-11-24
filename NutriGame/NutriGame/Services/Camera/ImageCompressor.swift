//
//  ImageCompressor.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import UIKit
import CoreGraphics

// MARK: - Image Compressor
/// Handles image compression according to NutriGame specifications:
/// - JPEG quality: 0.7
/// - Max resolution: 1080px on longest side
/// - Max file size: 500KB
struct ImageCompressor {

    // MARK: - Configuration

    struct Config {
        let maxDimension: CGFloat
        let jpegQuality: CGFloat
        let maxFileSizeKB: Int

        static let `default` = Config(
            maxDimension: 1080,
            jpegQuality: 0.7,
            maxFileSizeKB: 500
        )

        static let avatar = Config(
            maxDimension: 512,
            jpegQuality: 0.8,
            maxFileSizeKB: 250
        )

        static let thumbnail = Config(
            maxDimension: 256,
            jpegQuality: 0.6,
            maxFileSizeKB: 50
        )
    }

    // MARK: - Compression

    /// Compresses an image according to the specified configuration
    /// - Parameters:
    ///   - image: The original UIImage to compress
    ///   - config: Compression configuration (default: .default)
    /// - Returns: Compressed image data, or nil if compression fails
    static func compress(
        _ image: UIImage,
        config: Config = .default
    ) -> Data? {
        // Step 1: Resize if needed
        let resizedImage = resize(image, maxDimension: config.maxDimension)

        // Step 2: Compress to JPEG
        var quality = config.jpegQuality
        var compressedData = resizedImage.jpegData(compressionQuality: quality)

        // Step 3: Reduce quality until under max file size
        let maxBytes = config.maxFileSizeKB * 1024

        while let data = compressedData,
              data.count > maxBytes,
              quality > 0.1 {
            quality -= 0.1
            compressedData = resizedImage.jpegData(compressionQuality: quality)
        }

        return compressedData
    }

    /// Compresses an image and returns both the data and a preview UIImage
    static func compressWithPreview(
        _ image: UIImage,
        config: Config = .default
    ) -> (data: Data, preview: UIImage)? {
        guard let data = compress(image, config: config),
              let preview = UIImage(data: data) else {
            return nil
        }
        return (data, preview)
    }

    // MARK: - Resize

    /// Resizes an image to fit within maxDimension while maintaining aspect ratio
    static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size

        // Check if resize is needed
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }

        // Calculate new size
        let ratio = size.width / size.height
        let newSize: CGSize

        if size.width > size.height {
            newSize = CGSize(
                width: maxDimension,
                height: maxDimension / ratio
            )
        } else {
            newSize = CGSize(
                width: maxDimension * ratio,
                height: maxDimension
            )
        }

        // Perform resize
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    // MARK: - Square Crop (for Avatars)

    /// Crops an image to a square from the center
    static func cropToSquare(_ image: UIImage) -> UIImage {
        let size = image.size
        let minDimension = min(size.width, size.height)

        let x = (size.width - minDimension) / 2
        let y = (size.height - minDimension) / 2
        let cropRect = CGRect(x: x, y: y, width: minDimension, height: minDimension)

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Crops to square and compresses for avatar use
    static func processAvatar(_ image: UIImage) -> Data? {
        let squared = cropToSquare(image)
        return compress(squared, config: .avatar)
    }

    // MARK: - Thumbnail Generation

    /// Creates a small thumbnail for gallery previews
    static func createThumbnail(_ image: UIImage) -> Data? {
        return compress(image, config: .thumbnail)
    }

    // MARK: - Utilities

    /// Returns the file size of image data in a human-readable format
    static func fileSizeString(for data: Data) -> String {
        let bytes = data.count
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024)
        } else {
            return String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
        }
    }

    /// Checks if the image data is within the allowed size limit
    static func isWithinSizeLimit(_ data: Data, maxKB: Int = 500) -> Bool {
        return data.count <= maxKB * 1024
    }

    /// Returns the dimensions of an image
    static func dimensions(of image: UIImage) -> String {
        return "\(Int(image.size.width)) × \(Int(image.size.height))"
    }
}

// MARK: - Async Compression
extension ImageCompressor {

    /// Compresses an image asynchronously
    static func compressAsync(
        _ image: UIImage,
        config: Config = .default
    ) async -> Data? {
        return await Task.detached(priority: .userInitiated) {
            compress(image, config: config)
        }.value
    }

    /// Compresses multiple images asynchronously
    static func compressMultipleAsync(
        _ images: [UIImage],
        config: Config = .default
    ) async -> [Data] {
        await withTaskGroup(of: Data?.self) { group in
            for image in images {
                group.addTask {
                    compress(image, config: config)
                }
            }

            var results: [Data] = []
            for await data in group {
                if let data = data {
                    results.append(data)
                }
            }
            return results
        }
    }
}

// MARK: - UIImage Extension for Convenience
extension UIImage {

    /// Compresses the image for upload
    func compressForUpload() -> Data? {
        ImageCompressor.compress(self)
    }

    /// Compresses the image for avatar use
    func compressForAvatar() -> Data? {
        ImageCompressor.processAvatar(self)
    }

    /// Creates a thumbnail of the image
    func createThumbnail() -> Data? {
        ImageCompressor.createThumbnail(self)
    }

    /// Returns the file size after compression
    func compressedFileSize() -> String? {
        guard let data = compressForUpload() else { return nil }
        return ImageCompressor.fileSizeString(for: data)
    }

    /// Resizes the image to fit within maxDimension
    func resized(maxDimension: CGFloat) -> UIImage {
        ImageCompressor.resize(self, maxDimension: maxDimension)
    }

    /// Crops the image to a square
    func croppedToSquare() -> UIImage {
        ImageCompressor.cropToSquare(self)
    }
}

// MARK: - Image Loading from URL
extension ImageCompressor {

    /// Downloads and compresses an image from a URL
    static func downloadAndCompress(
        from url: URL,
        config: Config = .default
    ) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)

        guard let image = UIImage(data: data) else {
            throw ImageError.invalidImageData
        }

        guard let compressed = compress(image, config: config) else {
            throw ImageError.compressionFailed
        }

        return compressed
    }
}

// MARK: - Image Error
enum ImageError: LocalizedError {
    case invalidImageData
    case compressionFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Dados de imagem inválidos"
        case .compressionFailed:
            return "Falha ao comprimir imagem"
        case .saveFailed:
            return "Falha ao salvar imagem"
        }
    }
}

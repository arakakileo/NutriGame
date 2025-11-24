//
//  ImageCompressorTests.swift
//  NutriGameTests
//
//  Created by NutriGame Team
//

import XCTest
@testable import NutriGame

final class ImageCompressorTests: XCTestCase {

    // MARK: - Test Image Helper

    func createTestImage(size: CGSize, color: UIColor = .red) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Resize Tests

    func testResizeDoesNotEnlargeSmallImages() {
        let smallImage = createTestImage(size: CGSize(width: 500, height: 500))
        let resized = ImageCompressor.resize(smallImage, maxDimension: 1080)

        XCTAssertEqual(resized.size.width, 500)
        XCTAssertEqual(resized.size.height, 500)
    }

    func testResizeLandscapeImage() {
        let landscapeImage = createTestImage(size: CGSize(width: 2000, height: 1000))
        let resized = ImageCompressor.resize(landscapeImage, maxDimension: 1080)

        XCTAssertEqual(resized.size.width, 1080)
        XCTAssertEqual(resized.size.height, 540)
    }

    func testResizePortraitImage() {
        let portraitImage = createTestImage(size: CGSize(width: 1000, height: 2000))
        let resized = ImageCompressor.resize(portraitImage, maxDimension: 1080)

        XCTAssertEqual(resized.size.width, 540)
        XCTAssertEqual(resized.size.height, 1080)
    }

    func testResizeSquareImage() {
        let squareImage = createTestImage(size: CGSize(width: 2000, height: 2000))
        let resized = ImageCompressor.resize(squareImage, maxDimension: 1080)

        XCTAssertEqual(resized.size.width, 1080)
        XCTAssertEqual(resized.size.height, 1080)
    }

    // MARK: - Square Crop Tests

    func testCropToSquareLandscape() {
        let landscapeImage = createTestImage(size: CGSize(width: 200, height: 100))
        let cropped = ImageCompressor.cropToSquare(landscapeImage)

        XCTAssertEqual(cropped.size.width, cropped.size.height)
        XCTAssertEqual(cropped.size.width, 100)
    }

    func testCropToSquarePortrait() {
        let portraitImage = createTestImage(size: CGSize(width: 100, height: 200))
        let cropped = ImageCompressor.cropToSquare(portraitImage)

        XCTAssertEqual(cropped.size.width, cropped.size.height)
        XCTAssertEqual(cropped.size.width, 100)
    }

    func testCropToSquareAlreadySquare() {
        let squareImage = createTestImage(size: CGSize(width: 100, height: 100))
        let cropped = ImageCompressor.cropToSquare(squareImage)

        XCTAssertEqual(cropped.size.width, 100)
        XCTAssertEqual(cropped.size.height, 100)
    }

    // MARK: - Compression Tests

    func testCompressReturnsData() {
        let image = createTestImage(size: CGSize(width: 500, height: 500))
        let data = ImageCompressor.compress(image)

        XCTAssertNotNil(data)
        XCTAssertGreaterThan(data?.count ?? 0, 0)
    }

    func testCompressReducesLargeImage() {
        let largeImage = createTestImage(size: CGSize(width: 3000, height: 3000))
        let data = ImageCompressor.compress(largeImage, config: .default)

        XCTAssertNotNil(data)

        // Check resulting image dimensions
        if let compressedData = data, let resultImage = UIImage(data: compressedData) {
            XCTAssertLessThanOrEqual(resultImage.size.width, 1080)
            XCTAssertLessThanOrEqual(resultImage.size.height, 1080)
        }
    }

    func testCompressWithinSizeLimit() {
        let image = createTestImage(size: CGSize(width: 2000, height: 2000))
        let data = ImageCompressor.compress(image, config: .default)

        XCTAssertNotNil(data)
        XCTAssertLessThanOrEqual(data?.count ?? Int.max, 500 * 1024) // 500KB
    }

    // MARK: - Configuration Tests

    func testDefaultConfig() {
        let config = ImageCompressor.Config.default

        XCTAssertEqual(config.maxDimension, 1080)
        XCTAssertEqual(config.jpegQuality, 0.7)
        XCTAssertEqual(config.maxFileSizeKB, 500)
    }

    func testAvatarConfig() {
        let config = ImageCompressor.Config.avatar

        XCTAssertEqual(config.maxDimension, 512)
        XCTAssertEqual(config.jpegQuality, 0.8)
        XCTAssertEqual(config.maxFileSizeKB, 250)
    }

    func testThumbnailConfig() {
        let config = ImageCompressor.Config.thumbnail

        XCTAssertEqual(config.maxDimension, 256)
        XCTAssertEqual(config.jpegQuality, 0.6)
        XCTAssertEqual(config.maxFileSizeKB, 50)
    }

    // MARK: - Utility Tests

    func testFileSizeString() {
        XCTAssertEqual(ImageCompressor.fileSizeString(for: Data(count: 500)), "500 B")
        XCTAssertEqual(ImageCompressor.fileSizeString(for: Data(count: 1024)), "1.0 KB")
        XCTAssertEqual(ImageCompressor.fileSizeString(for: Data(count: 512 * 1024)), "512.0 KB")
        XCTAssertEqual(ImageCompressor.fileSizeString(for: Data(count: 1024 * 1024)), "1.0 MB")
    }

    func testIsWithinSizeLimit() {
        let smallData = Data(count: 100 * 1024) // 100KB
        let largeData = Data(count: 600 * 1024) // 600KB

        XCTAssertTrue(ImageCompressor.isWithinSizeLimit(smallData, maxKB: 500))
        XCTAssertFalse(ImageCompressor.isWithinSizeLimit(largeData, maxKB: 500))
    }

    func testDimensions() {
        let image = createTestImage(size: CGSize(width: 1920, height: 1080))
        let dimensions = ImageCompressor.dimensions(of: image)

        XCTAssertEqual(dimensions, "1920 × 1080")
    }

    // MARK: - Avatar Processing Tests

    func testProcessAvatar() {
        let image = createTestImage(size: CGSize(width: 1000, height: 1500))
        let data = ImageCompressor.processAvatar(image)

        XCTAssertNotNil(data)

        if let avatarData = data, let resultImage = UIImage(data: avatarData) {
            // Should be square
            XCTAssertEqual(resultImage.size.width, resultImage.size.height)

            // Should be within avatar size limit
            XCTAssertLessThanOrEqual(resultImage.size.width, 512)
        }
    }

    // MARK: - Thumbnail Tests

    func testCreateThumbnail() {
        let image = createTestImage(size: CGSize(width: 1000, height: 1000))
        let data = ImageCompressor.createThumbnail(image)

        XCTAssertNotNil(data)

        if let thumbnailData = data, let resultImage = UIImage(data: thumbnailData) {
            XCTAssertLessThanOrEqual(resultImage.size.width, 256)
            XCTAssertLessThanOrEqual(resultImage.size.height, 256)
        }
    }
}

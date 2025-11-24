// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NutriGame",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NutriGame",
            targets: ["NutriGame"]),
    ],
    dependencies: [
        // Firebase iOS SDK
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "10.0.0"
        ),
    ],
    targets: [
        .target(
            name: "NutriGame",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ]),
        .testTarget(
            name: "NutriGameTests",
            dependencies: ["NutriGame"]),
    ]
)

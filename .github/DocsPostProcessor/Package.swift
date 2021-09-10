// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DocsPostProcessor",
    products: [
        .executable(
            name: "DocsPostProcessor",
            targets: ["DocsPostProcessor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.7.4"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "DocsPostProcessor",
            dependencies: [
                "SwiftSoup",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
    ]
)

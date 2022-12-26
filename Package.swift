// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCurrent",
    platforms: [.iOS(.v13), .macOS(.v11), .tvOS(.v14), .watchOS(.v7)],
    products: [
        .library(
            name: "SwiftCurrent",
            targets: ["SwiftCurrent"]),
        .library(
            name: "SwiftCurrent_UIKit",
            targets: ["SwiftCurrent_UIKit"]),
        .library(
            name: "SwiftCurrent_SwiftUI",
            targets: ["SwiftCurrent_SwiftUI"]),
        .library(
            name: "SwiftCurrent_Testing",
            targets: ["SwiftCurrent_Testing_ObjC", "SwiftCurrent_Testing"]),
        .executable(name: "SwiftCurrent_CLI",
                    targets: ["SwiftCurrent_CLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: Version("2.0.0-beta.1")),
        .package(url: "https://github.com/mattgallagher/CwlCatchException.git", from: Version("2.0.0-beta.1")),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/sindresorhus/ExceptionCatcher", from: "2.0.0"),
        .package(url: "git@github.com:Tyler-Keith-Thompson/ViewInspector.git", branch: "fix-namespace-issue"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.10.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.3"),
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50600.1"))
    ],
    targets: [
        .target(
            name: "SwiftCurrent",
            dependencies: []),
        .target(
            name: "SwiftCurrent_UIKit",
            dependencies: ["SwiftCurrent"]),
        .target(
            name: "SwiftCurrent_SwiftUI",
            dependencies: ["SwiftCurrent"]),
        .target(
            name: "SwiftCurrent_Testing_ObjC",
            dependencies: [],
            exclude: ["SwiftCurrent_UIKitTests-Bridging-Header.h", "SwiftUIExampleTests-Bridging-Header.h", "UIKitExampleTests-Bridging-Header.h"],
            publicHeadersPath: "Include"),
        .target(
            name: "SwiftCurrent_Testing",
            dependencies: ["SwiftCurrent_Testing_ObjC",
                           "SwiftCurrent"]),
        .target(name: "SwiftCurrent_CLI",
                dependencies: [
                    .product(name: "SwiftSyntax", package: "swift-syntax"),
                    .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                ]),
        .testTarget(
            name: "SwiftCurrentTests",
            dependencies: [
                "SwiftCurrent",
                "SwiftCurrent_Testing",
                "CwlPreconditionTesting",
                "CwlCatchException",
                "ExceptionCatcher",
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            exclude: ["Info.plist", "SwiftCurrent.xctestplan"]),
        .testTarget(
            name: "SwiftCurrent-SwiftUITests",
            dependencies: [
                "SwiftCurrent",
                "SwiftCurrent_Testing",
                "SwiftCurrent_SwiftUI",
                "CwlPreconditionTesting",
                "CwlCatchException",
                "ViewInspector",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            path: "Tests/SwiftCurrent_SwiftUITests"),
        .testTarget(
            name: "SwiftCurrentMultiPlatformTests",
            dependencies: [
                "SwiftCurrent",
                "SwiftCurrent_Testing"
            ]),
    ]
)

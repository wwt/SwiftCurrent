// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCurrent",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "SwiftCurrent",
            targets: ["SwiftCurrent"]),
        .library(
            name: "SwiftCurrent_UIKit",
            targets: ["SwiftCurrent_UIKit"]),
        .library(
            name: "BETA_SwiftCurrent_SwiftUI",
            targets: ["SwiftCurrent_SwiftUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: Version("2.0.0-beta.1")),
        .package(url: "https://github.com/mattgallagher/CwlCatchException.git", from: Version("2.0.0-beta.1")),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/sindresorhus/ExceptionCatcher", from: "2.0.0"),
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.8.1")
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
        .testTarget(
            name: "SwiftCurrentTests",
            dependencies: [
                "SwiftCurrent",
                "CwlPreconditionTesting",
                "CwlCatchException",
                "ExceptionCatcher",
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            exclude: ["Info.plist", "SwiftCurrent.xctestplan"]),
        .testTarget(
            name: "SwiftCurrent_SwiftUITests",
            dependencies: [
                "SwiftCurrent",
                "CwlPreconditionTesting",
                "CwlCatchException",
                "ViewInspector"
            ]),
    ]
)

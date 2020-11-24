// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Workflow",
    products: [
        .library(
            name: "Workflow",
            targets: ["Workflow"]),
        .library(
            name: "WorkflowDI",
            targets: ["WorkflowDI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.7.1"),
    ],
    targets: [
        .target(
            name: "Workflow",
            dependencies: []),
        .target(
            name: "WorkflowDI",
            dependencies: ["Workflow", "Swinject"],
            path: "Sources/DependencyInjection"),
        .testTarget(
            name: "DependencyInjectionTests",
            dependencies: [
                "Workflow",
                "WorkflowDI",
            ],
            exclude: ["Info.plist"]),
    ]
)

// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Workflow",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Workflow",
            targets: ["Workflow"]),
        .library(
            name: "WorkflowDI",
            targets: ["WorkflowDI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: Version("2.0.0-beta.1")),
        .package(url: "https://github.com/mattgallagher/CwlCatchException.git", from: Version("2.0.0-beta.1")),
        .package(url: "https://github.com/nallick/UIUTest.git", from: Version("1.7.0")),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.7.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
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
                "CwlPreconditionTesting",
                "CwlCatchException",
            ],
            exclude: ["Info.plist"]),
    ]
)

// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Vibe",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Vibe",
            targets: ["Vibe"]),
    ],
    dependencies: [
        .package(url: "/Users/jonaszell/Developer/Cryo", branch: "dev"),
    ],
    targets: [
        .target(
            name: "Vibe",
            dependencies: ["Cryo"]),
        .testTarget(
            name: "VibeTests",
            dependencies: ["Vibe", "Cryo"]),
    ]
)

// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CedroStreamingSocket",
    products: [
        .library(
            name: "CedroStreamingSocket",
            targets: ["CedroStreamingSocket"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CedroStreamingSocket",
            dependencies: []),
        .testTarget(
            name: "CedroStreamingSocketTests",
            dependencies: ["CedroStreamingSocket"]),
    ]
)

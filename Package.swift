// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CedroStreamingSocket",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CedroStreamingSocket",
            targets: ["CedroStreamingSocket"]),
    ],
    dependencies: [
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", from: "7.6.4")
    ],
    targets: [
        .target(
            name: "CedroStreamingSocket",
            dependencies: ["CocoaAsyncSocket"]),
        .testTarget(
            name: "CedroStreamingSocketTests",
            dependencies: ["CedroStreamingSocket"]),
    ]
)

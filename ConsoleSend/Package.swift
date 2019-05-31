// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConsoleSend",
    dependencies: [
        .package(url: "https://github.com/kylebrowning/swift-nio-http2-apns.git", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ConsoleSend",
            dependencies: ["NIOAPNS"]),
        .testTarget(
            name: "ConsoleSendTests",
            dependencies: ["ConsoleSend"]),
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Monotonic",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Monotonic",
            targets: ["Monotonic"]),
        .executable(name: "Server",
                    targets: ["Server", "Monotonic"])
    ],
    dependencies: [
//        .package(url: "https://github.com/apple/swift-distributed-actors/", branch: "main"),
//        .package(url: "https://github.com/apple/swift-nio.git", from: "2.12.0"),
//        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.0.0"),
        .package(url: "https://github.com/samalone/websocket-actor-system.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Monotonic",
            dependencies: [
                // These dependencies are used by the WebSocketActorSystem
//                .product(name: "NIO", package: "swift-nio"),
//                .product(name: "NIOHTTP1", package: "swift-nio"),
//                .product(name: "NIOWebSocket", package: "swift-nio"),
//                .product(name: "NIOTransportServices", package: "swift-nio-transport-services"),
                .product(name: "WebSocketActors", package: "websocket-actor-system"),
            ]),
        .executableTarget(
            name: "Server",
            dependencies: [
                "Monotonic",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
//                .product(name: "DistributedCluster", package: "swift-distributed-actors"),
            ]
        ),
        .testTarget(
            name: "MonotonicTests",
            dependencies: ["Monotonic"]),
    ]
)

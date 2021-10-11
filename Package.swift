// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "VaporBackEnd",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.3.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/MihaelIsaev/FCM.git", from: "2.7.0"),
        .package(url: "https://github.com/vapor/apns.git", from: "2.0.0"),
        .package(url: "https://github.com/nodes-vapor/gatekeeper.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Leaf", package: "leaf"),
            .product(name: "FCM", package: "FCM"),
            .product(name: "APNS", package: "apns"),
            .product(name: "Gatekeeper", package: "gatekeeper")
        ]),
        .target(name: "Run", dependencies: [
            .target(name: "App"),
        ]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
        ])
    ]
)


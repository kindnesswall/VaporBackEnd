// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "VaporBackEnd",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-postgresql.git",from:"1.0.0"),
        .package(url: "https://github.com/vapor/auth.git",from:"2.0.0"),
        .package(url: "https://github.com/Jinxiansen/Guardian.git", from: "3.0.0"),
        .package(url: "https://github.com/MihaelIsaev/FCM.git", from: "0.6.2"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor","FluentPostgreSQL","Authentication","Guardian","FCM"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)


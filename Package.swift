// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataClient",
    platforms: [
        .macOS(.v10_15), .iOS(.v14), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "CoreDataClient",
            targets: ["CoreDateService"]),
    ],
    targets: [
        .target(
            name: "CoreDateService"),
        .testTarget(
            name: "CoreDateServiceTests",
            dependencies: ["CoreDateService"]
        ),
    ]
)

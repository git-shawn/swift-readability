// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-readability",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Readability",
            targets: ["Readability"]
        ),
    ],
    targets: [
        .target(
            name: "Readability",
            dependencies: [
                "ReadabilityCore",
            ],
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "ReadabilityCore",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "ReadabilityTests",
            dependencies: ["Readability"]
        ),
    ]
)

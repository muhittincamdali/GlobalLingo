// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GlobalLingo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "GlobalLingo", targets: ["GlobalLingo"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GlobalLingo",
            path: "Sources",
            exclude: [
                "GlobalLingo.swift",
                "Advanced",
                "Domain",
                "Features",
                "Infrastructure",
                "Integrations",
                "Performance",
                "Presentation",
                "Security",
                "UI"
            ]
        )
    ]
)

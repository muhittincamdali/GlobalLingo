// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Shelf",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "Shelf", targets: ["Shelf"])],
    targets: [
        .target(name: "Shelf", resources: [.process("Resources")]),
    ]
)

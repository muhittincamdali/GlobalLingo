// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
        // Core library product
        .library(
            name: "GlobalLingo",
            targets: ["GlobalLingo"]
        ),
        
        // Specialized products for modular usage
        .library(
            name: "GlobalLingoCore",
            targets: ["GlobalLingoCore"]
        ),
        
        .library(
            name: "GlobalLingoFeatures", 
            targets: ["GlobalLingoFeatures"]
        ),
        
        .library(
            name: "GlobalLingoIntegrations",
            targets: ["GlobalLingoIntegrations"]
        ),
        
        .library(
            name: "GlobalLingoSecurity",
            targets: ["GlobalLingoSecurity"] 
        ),
        
        .library(
            name: "GlobalLingoAdvanced",
            targets: ["GlobalLingoAdvanced"]
        ),
        
        .library(
            name: "GlobalLingoUtilities",
            targets: ["GlobalLingoUtilities"]
        )
    ],
    dependencies: [
        // Network and HTTP
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        
        // Reactive Programming
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        
        // JSON and Data Processing
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        
        // Logging
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        
        // Cryptography (Additional)
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        
        // SQLite for Local Storage
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.0"),
        
        // KeychainAccess for Secure Storage
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0"),
        
        // Zip for File Compression
        .package(url: "https://github.com/marmelroy/Zip.git", from: "2.1.0"),
        
        // Lottie for Animations
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.3.0"),
        
        // SnapKit for Auto Layout
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0")
    ],
    targets: [
        // MARK: - Main Target
        .target(
            name: "GlobalLingo",
            dependencies: [
                "GlobalLingoCore",
                "GlobalLingoFeatures", 
                "GlobalLingoIntegrations",
                "GlobalLingoSecurity",
                "GlobalLingoAdvanced",
                "GlobalLingoUtilities"
            ],
            path: "Sources/GlobalLingo",
            resources: [
                .process("Resources")
            ]
        ),
        
        // MARK: - Core Target
        .target(
            name: "GlobalLingoCore",
            dependencies: [
                "GlobalLingoUtilities",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/Core",
            resources: [
                .process("Resources")
            ]
        ),
        
        // MARK: - Features Target
        .target(
            name: "GlobalLingoFeatures",
            dependencies: [
                "GlobalLingoCore",
                "GlobalLingoUtilities",
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "Lottie", package: "lottie-spm")
            ],
            path: "Sources/Features",
            resources: [
                .process("Resources")
            ]
        ),
        
        // MARK: - Integrations Target
        .target(
            name: "GlobalLingoIntegrations",
            dependencies: [
                "GlobalLingoCore",
                "GlobalLingoUtilities",
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "Zip", package: "Zip")
            ],
            path: "Sources/Integrations",
            resources: [
                .process("Resources")
            ]
        ),
        
        // MARK: - Performance Target
        .target(
            name: "GlobalLingoPerformance",
            dependencies: [
                "GlobalLingoCore",
                "GlobalLingoUtilities",
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/Performance",
            resources: [
                .process("Resources")
            ]
        ),
        
        // MARK: - Security Target
        .target(
            name: "GlobalLingoSecurity",
            dependencies: [
                "GlobalLingoCore",
                "GlobalLingoUtilities",
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "KeychainAccess", package: "KeychainAccess")
            ],
            path: "Sources/Security",
            resources: [
                .process("Resources")
            ]
        ),
        
        // MARK: - Advanced Target
        .target(
            name: "GlobalLingoAdvanced",
            dependencies: [
                "GlobalLingoCore",
                "GlobalLingoUtilities",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/Advanced",
            resources: [
                .process("Resources")
            ]
        ),
        
        // MARK: - Utilities Target
        .target(
            name: "GlobalLingoUtilities",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SnapKit", package: "SnapKit")
            ],
            path: "Sources/Utilities",
            resources: [
                .process("Resources")
            ]
        ),
        
        // MARK: - Test Targets
        .testTarget(
            name: "GlobalLingoTests",
            dependencies: [
                "GlobalLingo",
                "GlobalLingoCore",
                "GlobalLingoFeatures",
                "GlobalLingoIntegrations", 
                "GlobalLingoSecurity",
                "GlobalLingoAdvanced",
                "GlobalLingoUtilities"
            ],
            path: "Tests/GlobalLingoTests"
        ),
        
        .testTarget(
            name: "GlobalLingoCoreTests",
            dependencies: [
                "GlobalLingoCore",
                "GlobalLingoUtilities"
            ],
            path: "Tests/CoreTests"
        ),
        
        .testTarget(
            name: "GlobalLingoFeaturesTests",
            dependencies: [
                "GlobalLingoFeatures",
                "GlobalLingoCore",
                "GlobalLingoUtilities"
            ],
            path: "Tests/FeaturesTests"
        ),
        
        .testTarget(
            name: "GlobalLingoIntegrationsTests",
            dependencies: [
                "GlobalLingoIntegrations", 
                "GlobalLingoCore",
                "GlobalLingoUtilities"
            ],
            path: "Tests/IntegrationsTests"
        ),
        
        .testTarget(
            name: "GlobalLingoSecurityTests",
            dependencies: [
                "GlobalLingoSecurity",
                "GlobalLingoCore", 
                "GlobalLingoUtilities"
            ],
            path: "Tests/SecurityTests"
        ),
        
        .testTarget(
            name: "GlobalLingoAdvancedTests",
            dependencies: [
                "GlobalLingoAdvanced",
                "GlobalLingoCore",
                "GlobalLingoUtilities"
            ],
            path: "Tests/AdvancedTests"
        ),
        
        .testTarget(
            name: "GlobalLingoUtilitiesTests",
            dependencies: [
                "GlobalLingoUtilities"
            ],
            path: "Tests/UtilitiesTests"
        ),
        
        // MARK: - Performance Test Targets
        .testTarget(
            name: "GlobalLingoPerformanceTests",
            dependencies: [
                "GlobalLingo",
                "GlobalLingoCore",
                "GlobalLingoFeatures"
            ],
            path: "Tests/PerformanceTests"
        ),
        
        // MARK: - Integration Test Targets
        .testTarget(
            name: "GlobalLingoIntegrationTests",
            dependencies: [
                "GlobalLingo"
            ],
            path: "Tests/IntegrationTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
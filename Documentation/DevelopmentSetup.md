# 🛠️ Development Setup Guide

Complete development environment setup for GlobalLingo contributors and enterprise developers.

## Prerequisites

### System Requirements
- **macOS**: 12.0+ (Monterey or later)
- **Xcode**: 15.0+ with latest command line tools
- **Swift**: 5.9+ (included with Xcode)
- **Git**: 2.30+ with LFS support
- **Homebrew**: Latest version for package management

### Development Tools
- **Swift Package Manager**: For dependency management
- **SwiftLint**: Code style enforcement
- **SwiftFormat**: Code formatting
- **Xcode Instruments**: Performance profiling
- **iOS Simulator**: Testing across devices

## Environment Setup

### 1. Clone Repository

```bash
# Clone with submodules
git clone --recursive https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo

# Configure Git for development
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### 2. Install Development Dependencies

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install SwiftLint and SwiftFormat
brew install swiftlint swiftformat

# Install pre-commit hooks
brew install pre-commit
pre-commit install
```

### 3. Xcode Configuration

```bash
# Open project in Xcode
open Package.swift

# Or use Xcode command line
xcodebuild -resolvePackageDependencies
```

### 4. Build Verification

```bash
# Verify Swift Package Manager setup
swift package resolve
swift package clean
swift build

# Run tests to verify setup
swift test

# Check code quality
swiftlint
swiftformat --lint .
```

## Development Workflow

### Local Development

```bash
# Start development server (if applicable)
swift run GlobalLingoServer

# Run specific tests
swift test --filter GlobalLingoTests.TranslationEngineTests

# Build for specific platforms
swift build --target GlobalLingo
swift build -c release
```

### Code Quality

```swift
// Example of proper coding standards
import Foundation
import GlobalLingo

/// Example class following GlobalLingo coding standards
public final class ExampleManager: ObservableObject {
    // MARK: - Properties
    
    private let globalLingo: GlobalLingoManager
    private let queue = DispatchQueue(label: "com.globallingo.example", qos: .userInitiated)
    
    // MARK: - Lifecycle
    
    public init(globalLingo: GlobalLingoManager = GlobalLingoManager()) {
        self.globalLingo = globalLingo
        setupConfiguration()
    }
    
    // MARK: - Public Methods
    
    public func performExample() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            globalLingo.translate(
                text: "Hello, World!",
                to: "es",
                from: "en"
            ) { result in
                switch result {
                case .success(let translation):
                    continuation.resume(returning: translation.translatedText)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupConfiguration() {
        // Configuration setup
    }
}
```

### Testing Strategy

```swift
import XCTest
@testable import GlobalLingo

final class ExampleManagerTests: XCTestCase {
    private var sut: ExampleManager!
    private var mockGlobalLingo: MockGlobalLingoManager!
    
    override func setUp() {
        super.setUp()
        mockGlobalLingo = MockGlobalLingoManager()
        sut = ExampleManager(globalLingo: mockGlobalLingo)
    }
    
    override func tearDown() {
        sut = nil
        mockGlobalLingo = nil
        super.tearDown()
    }
    
    func testPerformExample_Success() async throws {
        // Given
        let expectedTranslation = "¡Hola, Mundo!"
        mockGlobalLingo.stubbedTranslateResult = .success(
            Translation(translatedText: expectedTranslation)
        )
        
        // When
        let result = try await sut.performExample()
        
        // Then
        XCTAssertEqual(result, expectedTranslation)
        XCTAssertTrue(mockGlobalLingo.translateCalled)
    }
}
```

## Performance Development

### Profiling Setup

```bash
# Profile memory usage
instruments -t "Allocations" -D trace.trace ./your-app

# Profile CPU usage
instruments -t "Time Profiler" -D cpu-trace.trace ./your-app

# Profile network activity
instruments -t "Network" -D network-trace.trace ./your-app
```

### Optimization Guidelines

```swift
// Performance-optimized example
public final class PerformanceOptimizedManager {
    private let cache = NSCache<NSString, AnyObject>()
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    public func optimizedTranslation(_ text: String) async -> String? {
        // Check cache first
        if let cached = cache.object(forKey: text as NSString) as? String {
            return cached
        }
        
        // Perform translation with proper queue management
        return await withTaskGroup(of: String?.self) { group in
            group.addTask {
                // Actual translation work
                return await self.performTranslation(text)
            }
            
            return await group.first(where: { $0 != nil }) ?? nil
        }
    }
    
    private func performTranslation(_ text: String) async -> String? {
        // Implementation
        return nil
    }
}
```

## Security Development

### Secure Coding Practices

```swift
import CryptoKit
import GlobalLingo

public final class SecureManager {
    private let keychain = SecureKeychain()
    
    public func secureTranslation(_ sensitiveText: String) async throws -> String {
        // Encrypt sensitive data before processing
        let encryptedData = try encrypt(sensitiveText)
        
        // Process with GlobalLingo
        let result = try await processSecurely(encryptedData)
        
        // Decrypt and return
        return try decrypt(result)
    }
    
    private func encrypt(_ text: String) throws -> Data {
        guard let data = text.data(using: .utf8) else {
            throw SecurityError.invalidData
        }
        
        let key = try keychain.retrieveOrCreateKey(for: "translation_key")
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined
    }
    
    private func decrypt(_ data: Data) throws -> String {
        let key = try keychain.retrieveKey(for: "translation_key")
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let result = String(data: decryptedData, encoding: .utf8) else {
            throw SecurityError.decryptionFailed
        }
        
        return result
    }
}

public enum SecurityError: Error {
    case invalidData
    case decryptionFailed
}
```

## Contributing Guidelines

### Pull Request Process

1. **Fork and Branch**
```bash
git checkout -b feature/your-feature-name
```

2. **Implement Changes**
- Follow Swift API Design Guidelines
- Maintain 100% test coverage
- Update documentation

3. **Verify Quality**
```bash
# Run all quality checks
swiftlint
swiftformat --lint .
swift test
swift build -c release
```

4. **Submit PR**
```bash
git push origin feature/your-feature-name
# Create PR through GitHub interface
```

### Code Review Checklist

- [ ] **Functionality**: Code works as intended
- [ ] **Tests**: 100% test coverage maintained
- [ ] **Performance**: No performance regressions
- [ ] **Security**: Secure coding practices followed
- [ ] **Documentation**: All public APIs documented
- [ ] **Style**: SwiftLint and SwiftFormat pass
- [ ] **Architecture**: Follows established patterns

## Debugging and Troubleshooting

### Common Issues

**Issue**: Build failures after dependency updates
```bash
# Solution
rm -rf .build
swift package reset
swift package resolve
swift build
```

**Issue**: Test failures in CI but not locally
```bash
# Solution - Run tests in clean environment
swift package clean
swift test --parallel
```

**Issue**: Performance degradation
```bash
# Solution - Profile and analyze
instruments -t "Time Profiler" ./your-app
# Review Instruments trace for bottlenecks
```

### Development Tools

```swift
// Debug configuration for development
#if DEBUG
extension GlobalLingoManager {
    static let debug = GlobalLingoManager(
        configuration: GlobalLingoConfiguration(
            debugMode: true,
            enablePerformanceMonitoring: true,
            logLevel: .verbose
        )
    )
}
#endif
```

## Enterprise Development

### Enterprise Configuration

```swift
// Enterprise development setup
let enterpriseConfig = GlobalLingoConfiguration()
enterpriseConfig.enableEnterpriseFeatures = true
enterpriseConfig.enableAuditLogging = true
enterpriseConfig.enableComplianceMode = true
enterpriseConfig.enableCustomBranding = true

// Security hardening
enterpriseConfig.securityConfig.enableCertificatePinning = true
enterpriseConfig.securityConfig.enableBiometricAuth = true
enterpriseConfig.securityConfig.enableDataLossPrevention = true

let enterpriseManager = GlobalLingoManager(configuration: enterpriseConfig)
```

### Deployment Preparation

```bash
# Prepare for enterprise deployment
swift build -c release --arch arm64 --arch x86_64
codesign --force --sign "Developer ID Application: Your Name" ./GlobalLingo
notarytool submit GlobalLingo.zip --keychain-profile "AC_PASSWORD"
```

## Support and Resources

### Development Community
- **Discord**: [GlobalLingo Developers](https://discord.gg/globallingo-dev)
- **Slack**: [#development channel](https://globallingo.slack.com/channels/development)
- **Stack Overflow**: [GlobalLingo tag](https://stackoverflow.com/questions/tagged/globallingo)

### Enterprise Support
- **Enterprise Developers**: enterprise-dev@globallingo.com
- **Technical Architecture**: architecture@globallingo.com
- **Security Queries**: security@globallingo.com

For additional resources, see [API Reference](API.md) and [Architecture Guide](Architecture.md).

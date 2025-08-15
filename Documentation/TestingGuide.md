# 🧪 Testing Guide

Comprehensive testing strategy and implementation guide for GlobalLingo.

## Testing Philosophy

GlobalLingo maintains **100% test coverage** with a focus on:
- **Unit Testing**: Individual component validation
- **Integration Testing**: Cross-component interaction verification
- **Performance Testing**: Speed and memory usage validation
- **Security Testing**: Vulnerability and encryption validation
- **UI Testing**: User interface and experience validation

## Test Architecture

### Test Pyramid Structure

```
           📱 UI Tests (5%)
         🔗 Integration Tests (25%)
    🧩 Unit Tests (70%)
```

## Unit Testing

### Basic Test Structure

```swift
import XCTest
@testable import GlobalLingo

final class TranslationEngineTests: XCTestCase {
    private var sut: TranslationEngine!
    private var mockNetworkService: MockNetworkService!
    private var mockCacheManager: MockCacheManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockCacheManager = MockCacheManager()
        sut = TranslationEngine(
            networkService: mockNetworkService,
            cacheManager: mockCacheManager
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        mockCacheManager = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func testTranslate_WithValidInput_ReturnsTranslation() async throws {
        // Given
        let inputText = "Hello, world!"
        let expectedTranslation = "¡Hola, mundo!"
        mockNetworkService.stubbedTranslateResult = .success(
            TranslationResponse(translatedText: expectedTranslation)
        )
        
        // When
        let result = try await sut.translate(
            text: inputText,
            from: "en",
            to: "es"
        )
        
        // Then
        XCTAssertEqual(result.translatedText, expectedTranslation)
        XCTAssertEqual(result.sourceLanguage, "en")
        XCTAssertEqual(result.targetLanguage, "es")
        XCTAssertTrue(mockNetworkService.translateCalled)
    }
    
    // MARK: - Error Cases
    
    func testTranslate_WithNetworkError_ThrowsError() async {
        // Given
        mockNetworkService.stubbedTranslateResult = .failure(
            NetworkError.connectionFailed
        )
        
        // When/Then
        do {
            _ = try await sut.translate(text: "Hello", from: "en", to: "es")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    // MARK: - Performance Tests
    
    func testTranslate_PerformanceWithLargeText() {
        let largeText = String(repeating: "Hello world! ", count: 1000)
        
        measure {
            // Performance measurement
            _ = sut.prepareTranslation(text: largeText)
        }
    }
}
```

### Mock Objects

```swift
// Mock NetworkService for testing
final class MockNetworkService: NetworkServiceProtocol {
    var translateCalled = false
    var stubbedTranslateResult: Result<TranslationResponse, Error>?
    
    func translate(
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String
    ) async throws -> TranslationResponse {
        translateCalled = true
        
        guard let result = stubbedTranslateResult else {
            throw TestError.noStubbedResult
        }
        
        return try result.get()
    }
}

// Mock CacheManager for testing
final class MockCacheManager: CacheManagerProtocol {
    private var cache: [String: Any] = [:]
    
    func store<T>(_ value: T, forKey key: String) {
        cache[key] = value
    }
    
    func retrieve<T>(forKey key: String, type: T.Type) -> T? {
        return cache[key] as? T
    }
    
    func remove(forKey key: String) {
        cache.removeValue(forKey: key)
    }
}
```

## Integration Testing

### Cross-Component Testing

```swift
final class GlobalLingoIntegrationTests: XCTestCase {
    private var globalLingo: GlobalLingoManager!
    
    override func setUp() {
        super.setUp()
        globalLingo = GlobalLingoManager(
            configuration: GlobalLingoConfiguration(
                debugMode: true,
                enableTestMode: true
            )
        )
    }
    
    func testFullTranslationWorkflow() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Translation completed")
        var translationResult: Translation?
        
        // When
        globalLingo.translate(
            text: "Good morning",
            to: "fr",
            from: "en"
        ) { result in
            switch result {
            case .success(let translation):
                translationResult = translation
            case .failure:
                XCTFail("Translation should succeed in test mode")
            }
            expectation.fulfill()
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertNotNil(translationResult)
        XCTAssertEqual(translationResult?.sourceLanguage, "en")
        XCTAssertEqual(translationResult?.targetLanguage, "fr")
    }
    
    func testVoiceRecognitionIntegration() async throws {
        // Test voice recognition with translation pipeline
        let testAudioData = generateTestAudioData()
        let expectation = XCTestExpectation(description: "Voice recognition completed")
        
        globalLingo.recognizeVoice(
            audioData: testAudioData,
            language: "en"
        ) { result in
            switch result {
            case .success(let recognition):
                XCTAssertFalse(recognition.recognizedText.isEmpty)
                XCTAssertGreaterThan(recognition.confidence, 0.5)
            case .failure(let error):
                XCTFail("Voice recognition failed: \(error)")
            }
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    private func generateTestAudioData() -> Data {
        // Generate test audio data for testing
        return Data(count: 1024)
    }
}
```

## Performance Testing

### Memory and Speed Testing

```swift
final class PerformanceTests: XCTestCase {
    private var globalLingo: GlobalLingoManager!
    
    override func setUp() {
        super.setUp()
        globalLingo = GlobalLingoManager()
    }
    
    func testTranslationPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = XCTestExpectation(description: "Performance test")
            
            globalLingo.translate(
                text: "Performance test string",
                to: "es",
                from: "en"
            ) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    func testConcurrentTranslations() {
        let concurrentCount = 10
        let expectations = (0..<concurrentCount).map { _ in
            XCTestExpectation(description: "Concurrent translation")
        }
        
        measure {
            for (index, expectation) in expectations.enumerated() {
                globalLingo.translate(
                    text: "Concurrent test \(index)",
                    to: "fr",
                    from: "en"
                ) { _ in
                    expectation.fulfill()
                }
            }
            
            wait(for: expectations, timeout: 5.0)
        }
    }
    
    func testMemoryUsageUnderLoad() {
        let initialMemory = getMemoryUsage()
        
        // Perform 100 translations
        for i in 0..<100 {
            let expectation = XCTestExpectation(description: "Translation \(i)")
            
            globalLingo.translate(
                text: "Memory test \(i)",
                to: "de",
                from: "en"
            ) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Assert memory increase is reasonable (< 50MB)
        XCTAssertLessThan(memoryIncrease, 50 * 1024 * 1024)
    }
    
    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        return result == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }
}
```

## Security Testing

### Encryption and Authentication Testing

```swift
final class SecurityTests: XCTestCase {
    private var securityManager: SecurityManager!
    
    override func setUp() {
        super.setUp()
        securityManager = SecurityManager()
    }
    
    func testDataEncryption() throws {
        // Given
        let sensitiveData = "Confidential translation data"
        let data = sensitiveData.data(using: .utf8)!
        
        // When
        let encryptedData = try securityManager.encrypt(data)
        let decryptedData = try securityManager.decrypt(encryptedData)
        let decryptedString = String(data: decryptedData, encoding: .utf8)
        
        // Then
        XCTAssertNotEqual(encryptedData, data)
        XCTAssertEqual(decryptedString, sensitiveData)
    }
    
    func testBiometricAuthentication() async throws {
        // Test biometric authentication flow
        let authenticationResult = try await securityManager.authenticateWithBiometrics(
            reason: "Test authentication"
        )
        
        XCTAssertTrue(authenticationResult.isAuthenticated)
        XCTAssertNotNil(authenticationResult.authenticationType)
    }
    
    func testKeyGeneration() throws {
        // Test cryptographic key generation
        let key1 = try securityManager.generateEncryptionKey()
        let key2 = try securityManager.generateEncryptionKey()
        
        XCTAssertNotEqual(key1, key2)
        XCTAssertEqual(key1.count, 32) // 256-bit key
    }
}
```

## UI Testing

### User Interface Testing

```swift
import XCTest

final class GlobalLingoUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testTranslationFlow() {
        // Test complete translation user flow
        let inputField = app.textFields["translationInput"]
        let translateButton = app.buttons["translateButton"]
        let outputLabel = app.staticTexts["translationOutput"]
        
        // Input text
        inputField.tap()
        inputField.typeText("Hello, world!")
        
        // Trigger translation
        translateButton.tap()
        
        // Verify output
        let expectation = XCTestExpectation(description: "Translation appears")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if outputLabel.exists && !outputLabel.label.isEmpty {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(outputLabel.exists)
        XCTAssertFalse(outputLabel.label.isEmpty)
    }
    
    func testVoiceRecognitionUI() {
        let voiceButton = app.buttons["voiceRecognitionButton"]
        let statusLabel = app.staticTexts["voiceStatus"]
        
        voiceButton.tap()
        
        // Verify voice recognition UI state
        XCTAssertTrue(statusLabel.exists)
        XCTAssertEqual(statusLabel.label, "Listening...")
    }
    
    func testAccessibility() {
        // Test accessibility features
        XCTAssertTrue(app.isAccessibilityElement)
        
        let inputField = app.textFields["translationInput"]
        XCTAssertEqual(inputField.accessibilityLabel, "Translation input")
        XCTAssertEqual(inputField.accessibilityHint, "Enter text to translate")
        
        let translateButton = app.buttons["translateButton"]
        XCTAssertEqual(translateButton.accessibilityLabel, "Translate")
        XCTAssertTrue(translateButton.isAccessibilityElement)
    }
}
```

## Test Data Management

### Test Fixtures

```swift
enum TestData {
    static let sampleTranslations = [
        Translation(
            originalText: "Hello",
            translatedText: "Hola",
            sourceLanguage: "en",
            targetLanguage: "es",
            confidence: 0.98
        ),
        Translation(
            originalText: "Good morning",
            translatedText: "Bonjour",
            sourceLanguage: "en",
            targetLanguage: "fr",
            confidence: 0.95
        )
    ]
    
    static let sampleAudioData: Data = {
        // Generate sample audio data for testing
        let sampleRate: Double = 44100
        let duration: Double = 1.0
        let samples = Int(sampleRate * duration)
        
        var audioData = Data()
        for i in 0..<samples {
            let sample = sin(2.0 * .pi * 440.0 * Double(i) / sampleRate)
            let intSample = Int16(sample * 32767)
            audioData.append(contentsOf: withUnsafeBytes(of: intSample) { Array($0) })
        }
        
        return audioData
    }()
}
```

## Continuous Integration

### GitHub Actions Testing

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode.app
    
    - name: Run Unit Tests
      run: swift test --enable-code-coverage
    
    - name: Run Integration Tests
      run: swift test --filter IntegrationTests
    
    - name: Run Performance Tests
      run: swift test --filter PerformanceTests
    
    - name: Generate Code Coverage
      run: |
        xcrun llvm-cov export -format="lcov" \
          .build/debug/GlobalLingoPackageTests.xctest/Contents/MacOS/GlobalLingoPackageTests \
          -instr-profile .build/debug/codecov/default.profdata > coverage.lcov
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.lcov
```

## Test Automation

### Running Tests

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter TranslationEngineTests

# Run with coverage
swift test --enable-code-coverage

# Run performance tests only
swift test --filter PerformanceTests

# Run tests in parallel
swift test --parallel

# Generate test report
swift test --enable-code-coverage --build-path .build
```

### Test Quality Metrics

```swift
// Test quality metrics collection
extension XCTestCase {
    func measureTestQuality() {
        let testCount = testInvocations.count
        let assertionCount = getAssertionCount()
        let coveragePercentage = getCodeCoverage()
        
        print("Test Quality Metrics:")
        print("- Test Count: \(testCount)")
        print("- Assertion Count: \(assertionCount)")
        print("- Coverage: \(coveragePercentage)%")
        
        // Quality gates
        XCTAssertGreaterThan(assertionCount, 0, "Tests must contain assertions")
        XCTAssertGreaterThan(coveragePercentage, 90, "Code coverage must be > 90%")
    }
}
```

## Best Practices

### Testing Guidelines

1. **Test Naming**: Use descriptive test names that explain the scenario
2. **AAA Pattern**: Arrange, Act, Assert structure for clarity
3. **Test Isolation**: Each test should be independent and repeatable
4. **Mock External Dependencies**: Use mocks for network, file system, etc.
5. **Performance Testing**: Include performance tests for critical paths
6. **Error Testing**: Test both success and failure scenarios
7. **Edge Cases**: Test boundary conditions and edge cases

### Code Coverage Goals

- **Unit Tests**: 100% coverage for business logic
- **Integration Tests**: 90%+ coverage for critical user flows
- **UI Tests**: 80%+ coverage for main user journeys
- **Overall**: 95%+ total code coverage

For more testing resources, see [Development Setup](DevelopmentSetup.md) and [API Reference](API.md).

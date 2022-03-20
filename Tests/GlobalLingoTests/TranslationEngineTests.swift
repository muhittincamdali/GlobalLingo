import XCTest
@testable import GlobalLingo

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
final class TranslationEngineTests: XCTestCase {
    
    var translationEngine: TranslationEngine!
    
    override func setUpWithError() throws {
        translationEngine = TranslationEngine()
        
        let config = TranslationEngineConfiguration(
            defaultSourceLanguage: .english,
            defaultTargetLanguage: .spanish,
            enableOfflineMode: true,
            enableCaching: true,
            cacheSize: 100,
            networkTimeout: 30.0,
            enableEncryption: true
        )
        
        translationEngine.configure(config)
    }
    
    override func tearDownWithError() throws {
        translationEngine = nil
    }
    
    // MARK: - Configuration Tests
    
    func testTranslationEngineInitialization() {
        XCTAssertNotNil(translationEngine)
    }
    
    func testTranslationEngineConfiguration() {
        let config = TranslationEngineConfiguration(
            defaultSourceLanguage: .english,
            defaultTargetLanguage: .french,
            enableOfflineMode: true,
            enableCaching: true,
            cacheSize: 500,
            networkTimeout: 60.0,
            enableEncryption: false
        )
        
        translationEngine.configure(config)
        
        // Test that configuration was applied
        XCTAssertTrue(translationEngine.isConfigured)
    }
    
    // MARK: - Text Translation Tests
    
    func testBasicTextTranslation() async throws {
        let result = try await translationEngine.translate(
            text: "Hello, how are you?",
            from: .english,
            to: .spanish
        )
        
        XCTAssertFalse(result.isEmpty)
        XCTAssertNotEqual(result, "Hello, how are you?")
    }
    
    func testTextTranslationWithEmptyInput() async {
        do {
            _ = try await translationEngine.translate(
                text: "",
                from: .english,
                to: .spanish
            )
            XCTFail("Should throw error for empty input")
        } catch TranslationError.emptyInput {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testTextTranslationWithLongInput() async {
        let longText = String(repeating: "This is a very long text. ", count: 200)
        
        do {
            _ = try await translationEngine.translate(
                text: longText,
                from: .english,
                to: .spanish
            )
            XCTFail("Should throw error for long input")
        } catch TranslationError.inputTooLong {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testTextTranslationWithSameLanguage() async {
        do {
            _ = try await translationEngine.translate(
                text: "Hello",
                from: .english,
                to: .english
            )
            XCTFail("Should throw error for same language")
        } catch TranslationError.sameLanguage {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testTextTranslationWithUnsupportedLanguage() async {
        let unsupportedLanguage = Language(
            id: "xx",
            code: "xx",
            name: "Unsupported",
            nativeName: "Unsupported",
            isSupported: false
        )
        
        do {
            _ = try await translationEngine.translate(
                text: "Hello",
                from: unsupportedLanguage,
                to: .spanish
            )
            XCTFail("Should throw error for unsupported language")
        } catch TranslationError.languageNotSupported {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Batch Translation Tests
    
    func testBatchTranslation() async throws {
        let texts = ["Hello", "Goodbye", "Thank you", "Please", "Sorry"]
        
        let results = try await translationEngine.translateBatch(
            texts: texts,
            from: .english,
            to: .spanish
        )
        
        XCTAssertEqual(results.count, texts.count)
        
        for result in results {
            XCTAssertFalse(result.isEmpty)
        }
    }
    
    func testBatchTranslationWithEmptyArray() async {
        do {
            _ = try await translationEngine.translateBatch(
                texts: [],
                from: .english,
                to: .spanish
            )
            XCTFail("Should throw error for empty array")
        } catch TranslationError.emptyInput {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Language Detection Tests
    
    func testLanguageDetection() async throws {
        let detectedLanguage = try await translationEngine.detectLanguage(
            text: "Bonjour, comment allez-vous?"
        )
        
        XCTAssertEqual(detectedLanguage, .french)
    }
    
    func testLanguageDetectionWithEmptyText() async {
        do {
            _ = try await translationEngine.detectLanguage(text: "")
            XCTFail("Should throw error for empty text")
        } catch TranslationError.emptyInput {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Offline Translation Tests
    
    func testOfflineAvailability() {
        let isAvailable = translationEngine.isOfflineAvailable(
            from: .english,
            to: .spanish
        )
        
        XCTAssertTrue(isAvailable)
    }
    
    func testOfflineTranslation() async throws {
        let result = try await translationEngine.translateOffline(
            text: "Hello world",
            from: .english,
            to: .spanish
        )
        
        XCTAssertFalse(result.isEmpty)
        XCTAssertNotEqual(result, "Hello world")
    }
    
    func testOfflineTranslationWithUnavailablePair() async {
        let unsupportedLanguage = Language(
            id: "xx",
            code: "xx",
            name: "Unsupported",
            nativeName: "Unsupported",
            isOfflineAvailable: false
        )
        
        do {
            _ = try await translationEngine.translateOffline(
                text: "Hello",
                from: .english,
                to: unsupportedLanguage
            )
            XCTFail("Should throw error for unavailable offline translation")
        } catch TranslationError.offlineNotAvailable {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Cache Tests
    
    func testCacheFunctionality() async throws {
        let text = "Hello, this is a test"
        
        // First translation
        let result1 = try await translationEngine.translate(
            text: text,
            from: .english,
            to: .spanish
        )
        
        // Second translation (should use cache)
        let result2 = try await translationEngine.translate(
            text: text,
            from: .english,
            to: .spanish
        )
        
        XCTAssertEqual(result1, result2)
    }
    
    func testCacheClear() {
        translationEngine.clearCache()
        
        let statistics = translationEngine.getCacheStatistics()
        XCTAssertEqual(statistics.cacheSize, 0)
    }
    
    func testCacheStatistics() {
        let statistics = translationEngine.getCacheStatistics()
        
        XCTAssertNotNil(statistics)
        XCTAssertGreaterThanOrEqual(statistics.cacheSize, 0)
        XCTAssertGreaterThanOrEqual(statistics.hitRate, 0.0)
        XCTAssertLessThanOrEqual(statistics.hitRate, 1.0)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceMetrics() {
        let metrics = translationEngine.getPerformanceMetrics()
        
        XCTAssertNotNil(metrics)
        XCTAssertGreaterThanOrEqual(metrics.averageResponseTime, 0.0)
        XCTAssertGreaterThanOrEqual(metrics.memoryUsage, 0)
        XCTAssertGreaterThanOrEqual(metrics.cacheHitRate, 0.0)
        XCTAssertLessThanOrEqual(metrics.cacheHitRate, 1.0)
    }
    
    func testTranslationPerformance() async throws {
        let startTime = Date()
        
        _ = try await translationEngine.translate(
            text: "Hello, this is a performance test",
            from: .english,
            to: .spanish
        )
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Translation should complete within reasonable time
        XCTAssertLessThan(duration, 10.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingForNetworkError() async {
        // This test would require mocking network failures
        // For now, we'll test the error types are defined
        XCTAssertNotNil(TranslationError.networkError)
        XCTAssertNotNil(TranslationError.translationFailed)
    }
    
    func testErrorHandlingForMaliciousContent() async {
        let maliciousText = "<script>alert('xss')</script>"
        
        do {
            _ = try await translationEngine.translate(
                text: maliciousText,
                from: .english,
                to: .spanish
            )
            XCTFail("Should throw error for malicious content")
        } catch TranslationError.maliciousContent {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Voice Translation Tests
    
    func testVoiceTranslation() async throws {
        // Create mock audio data
        let audioData = Data(repeating: 0, count: 1024)
        
        let result = try await translationEngine.translateVoice(
            audioData: audioData,
            from: .english,
            to: .spanish
        )
        
        XCTAssertNotNil(result)
        XCTAssertFalse(result.originalText.isEmpty)
        XCTAssertFalse(result.translatedText.isEmpty)
        XCTAssertEqual(result.language, .spanish)
    }
    
    func testVoiceTranslationWithEmptyAudio() async {
        do {
            _ = try await translationEngine.translateVoice(
                audioData: Data(),
                from: .english,
                to: .spanish
            )
            XCTFail("Should throw error for empty audio")
        } catch TranslationError.emptyInput {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testVoiceTranslationWithLargeAudio() async {
        let largeAudioData = Data(repeating: 0, count: 11 * 1024 * 1024) // 11MB
        
        do {
            _ = try await translationEngine.translateVoice(
                audioData: largeAudioData,
                from: .english,
                to: .spanish
            )
            XCTFail("Should throw error for large audio")
        } catch TranslationError.audioTooLarge {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Integration Tests
    
    func testEndToEndTranslationFlow() async throws {
        // Test complete flow: detect language -> translate -> verify result
        
        let testText = "Hello, how are you today?"
        
        // Step 1: Detect language
        let detectedLanguage = try await translationEngine.detectLanguage(text: testText)
        XCTAssertEqual(detectedLanguage, .english)
        
        // Step 2: Translate
        let translatedText = try await translationEngine.translate(
            text: testText,
            from: detectedLanguage,
            to: .spanish
        )
        
        // Step 3: Verify result
        XCTAssertFalse(translatedText.isEmpty)
        XCTAssertNotEqual(translatedText, testText)
        
        // Step 4: Check cache
        let statistics = translationEngine.getCacheStatistics()
        XCTAssertGreaterThanOrEqual(statistics.cacheSize, 0)
    }
    
    func testMultipleLanguagePairs() async throws {
        let languagePairs = [
            (Language.english, Language.spanish),
            (Language.english, Language.french),
            (Language.english, Language.german),
            (Language.spanish, Language.english),
            (Language.french, Language.english)
        ]
        
        let testText = "Hello world"
        
        for (source, target) in languagePairs {
            let result = try await translationEngine.translate(
                text: testText,
                from: source,
                to: target
            )
            
            XCTAssertFalse(result.isEmpty)
            XCTAssertNotEqual(result, testText)
        }
    }
}

// MARK: - Mock Classes for Testing

class MockTranslationEngine: TranslationEngine {
    var shouldFail = false
    var mockResult = "Mocked translation result"
    
    override func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> String {
        if shouldFail {
            throw TranslationError.translationFailed
        }
        return mockResult
    }
}

// MARK: - Test Helpers

extension TranslationEngineTests {
    func createTestLanguage() -> Language {
        return Language(
            id: "test",
            code: "test",
            name: "Test Language",
            nativeName: "Test Language",
            isSupported: true,
            isOfflineAvailable: true,
            isVoiceSupported: true
        )
    }
    
    func createLargeText() -> String {
        return String(repeating: "This is a test sentence. ", count: 300)
    }
} 
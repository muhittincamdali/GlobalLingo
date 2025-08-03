import Foundation
import Crypto
import Logging
import Metrics

/// Main translation engine for GlobalLingo
/// Handles text translation, voice translation, and language detection
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public class TranslationEngine: ObservableObject {
    
    // MARK: - Properties
    
    private let logger = Logger(label: "GlobalLingo.TranslationEngine")
    private let performanceMonitor = PerformanceMonitor()
    private let cacheManager = CacheManager()
    private let networkService = NetworkService()
    private let offlineService = OfflineService()
    private let securityManager = SecurityManager()
    
    private var configuration: TranslationEngineConfiguration?
    private var isConfigured = false
    
    // MARK: - Published Properties
    
    @Published public var isTranslating = false
    @Published public var translationProgress: Float = 0.0
    @Published public var lastTranslationResult: TranslationResult?
    @Published public var errorMessage: String?
    
    // MARK: - Initialization
    
    public init() {
        setupPerformanceMonitoring()
        setupErrorHandling()
    }
    
    // MARK: - Configuration
    
    /// Configure the translation engine with custom settings
    /// - Parameter config: Configuration object containing engine settings
    public func configure(_ config: TranslationEngineConfiguration) {
        self.configuration = config
        self.isConfigured = true
        
        // Configure sub-components
        cacheManager.configure(cacheSize: config.cacheSize)
        networkService.configure(timeout: config.networkTimeout)
        offlineService.configure(enableOffline: config.enableOfflineMode)
        securityManager.configure(encryptionEnabled: config.enableEncryption)
        
        logger.info("Translation engine configured successfully")
    }
    
    // MARK: - Text Translation
    
    /// Translate text from one language to another
    /// - Parameters:
    ///   - text: Text to translate
    ///   - from: Source language
    ///   - to: Target language
    /// - Returns: Translated text
    public func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> String {
        
        guard isConfigured else {
            throw TranslationError.engineNotConfigured
        }
        
        // Validate input
        try validateTranslationInput(text: text, from: sourceLanguage, to: targetLanguage)
        
        // Check cache first
        if let cachedResult = cacheManager.getCachedTranslation(
            text: text,
            from: sourceLanguage,
            to: targetLanguage
        ) {
            logger.info("Translation found in cache")
            return cachedResult
        }
        
        // Start translation
        await MainActor.run {
            isTranslating = true
            translationProgress = 0.0
            errorMessage = nil
        }
        
        do {
            // Determine translation strategy
            let strategy = determineTranslationStrategy(from: sourceLanguage, to: targetLanguage)
            
            // Perform translation
            let result = try await performTranslation(
                text: text,
                from: sourceLanguage,
                to: targetLanguage,
                strategy: strategy
            )
            
            // Cache result
            cacheManager.cacheTranslation(
                text: text,
                result: result,
                from: sourceLanguage,
                to: targetLanguage
            )
            
            // Update UI
            await MainActor.run {
                isTranslating = false
                translationProgress = 1.0
                lastTranslationResult = TranslationResult(
                    originalText: text,
                    translatedText: result,
                    sourceLanguage: sourceLanguage,
                    targetLanguage: targetLanguage,
                    timestamp: Date()
                )
            }
            
            // Track metrics
            performanceMonitor.trackTranslation(
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                textLength: text.count
            )
            
            return result
            
        } catch {
            await MainActor.run {
                isTranslating = false
                translationProgress = 0.0
                errorMessage = error.localizedDescription
            }
            
            logger.error("Translation failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Translate multiple texts in batch
    /// - Parameters:
    ///   - texts: Array of texts to translate
    ///   - from: Source language
    ///   - to: Target language
    /// - Returns: Array of translated texts
    public func translateBatch(
        texts: [String],
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> [String] {
        
        guard isConfigured else {
            throw TranslationError.engineNotConfigured
        }
        
        guard !texts.isEmpty else {
            throw TranslationError.emptyInput
        }
        
        // Validate all inputs
        for text in texts {
            try validateTranslationInput(text: text, from: sourceLanguage, to: targetLanguage)
        }
        
        await MainActor.run {
            isTranslating = true
            translationProgress = 0.0
            errorMessage = nil
        }
        
        var results: [String] = []
        let totalTexts = texts.count
        
        for (index, text) in texts.enumerated() {
            do {
                let result = try await translate(text: text, from: sourceLanguage, to: targetLanguage)
                results.append(result)
                
                // Update progress
                await MainActor.run {
                    translationProgress = Float(index + 1) / Float(totalTexts)
                }
                
            } catch {
                await MainActor.run {
                    isTranslating = false
                    translationProgress = 0.0
                    errorMessage = "Batch translation failed at text \(index + 1): \(error.localizedDescription)"
                }
                throw error
            }
        }
        
        await MainActor.run {
            isTranslating = false
            translationProgress = 1.0
        }
        
        return results
    }
    
    // MARK: - Voice Translation
    
    /// Translate voice from one language to another
    /// - Parameters:
    ///   - audioData: Audio data to translate
    ///   - from: Source language
    ///   - to: Target language
    /// - Returns: Voice translation result
    public func translateVoice(
        audioData: Data,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> VoiceTranslationResult {
        
        guard isConfigured else {
            throw TranslationError.engineNotConfigured
        }
        
        // Validate audio data
        try validateAudioData(audioData)
        
        await MainActor.run {
            isTranslating = true
            translationProgress = 0.0
            errorMessage = nil
        }
        
        do {
            // Step 1: Speech recognition
            let voiceRecognition = VoiceRecognition()
            voiceRecognition.configure(
                language: sourceLanguage,
                enableNoiseCancellation: true,
                enableAccentRecognition: true
            )
            
            let recognizedText = try await voiceRecognition.recognizeSpeech(audioData: audioData)
            
            await MainActor.run {
                translationProgress = 0.5
            }
            
            // Step 2: Text translation
            let translatedText = try await translate(
                text: recognizedText,
                from: sourceLanguage,
                to: targetLanguage
            )
            
            // Step 3: Text-to-speech (if supported)
            let synthesizedAudio = try await synthesizeSpeech(
                text: translatedText,
                language: targetLanguage
            )
            
            await MainActor.run {
                isTranslating = false
                translationProgress = 1.0
            }
            
            return VoiceTranslationResult(
                originalText: recognizedText,
                translatedText: translatedText,
                audioData: synthesizedAudio,
                confidence: 0.95,
                language: targetLanguage
            )
            
        } catch {
            await MainActor.run {
                isTranslating = false
                translationProgress = 0.0
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Language Detection
    
    /// Detect the language of given text
    /// - Parameter text: Text to detect language for
    /// - Returns: Detected language
    public func detectLanguage(text: String) async throws -> Language {
        
        guard isConfigured else {
            throw TranslationError.engineNotConfigured
        }
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TranslationError.emptyInput
        }
        
        do {
            let languageDetector = LanguageDetector()
            let detectedLanguage = try await languageDetector.detectLanguage(text: text)
            
            logger.info("Language detected: \(detectedLanguage.name)")
            return detectedLanguage
            
        } catch {
            logger.error("Language detection failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Offline Translation
    
    /// Check if offline translation is available for language pair
    /// - Parameters:
    ///   - from: Source language
    ///   - to: Target language
    /// - Returns: Boolean indicating offline availability
    public func isOfflineAvailable(from sourceLanguage: Language, to targetLanguage: Language) -> Bool {
        return offlineService.isOfflineAvailable(from: sourceLanguage, to: targetLanguage)
    }
    
    /// Translate text offline
    /// - Parameters:
    ///   - text: Text to translate
    ///   - from: Source language
    ///   - to: Target language
    /// - Returns: Translated text
    public func translateOffline(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> String {
        
        guard isConfigured else {
            throw TranslationError.engineNotConfigured
        }
        
        guard isOfflineAvailable(from: sourceLanguage, to: targetLanguage) else {
            throw TranslationError.offlineNotAvailable
        }
        
        try validateTranslationInput(text: text, from: sourceLanguage, to: targetLanguage)
        
        do {
            let result = try await offlineService.translateOffline(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            
            logger.info("Offline translation completed successfully")
            return result
            
        } catch {
            logger.error("Offline translation failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Cache Management
    
    /// Clear translation cache
    public func clearCache() {
        cacheManager.clearCache()
        logger.info("Translation cache cleared")
    }
    
    /// Get cache statistics
    public func getCacheStatistics() -> CacheStatistics {
        return cacheManager.getStatistics()
    }
    
    // MARK: - Performance Monitoring
    
    /// Get performance metrics
    public func getPerformanceMetrics() -> PerformanceMetrics {
        return performanceMonitor.getMetrics()
    }
    
    /// Enable performance monitoring
    public func enablePerformanceMonitoring() {
        performanceMonitor.enableMonitoring()
    }
    
    /// Disable performance monitoring
    public func disablePerformanceMonitoring() {
        performanceMonitor.disableMonitoring()
    }
    
    // MARK: - Private Methods
    
    private func validateTranslationInput(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) throws {
        
        // Check for empty text
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TranslationError.emptyInput
        }
        
        // Check text length
        guard text.count <= 5000 else {
            throw TranslationError.inputTooLong
        }
        
        // Check language support
        guard sourceLanguage.isSupported else {
            throw TranslationError.languageNotSupported
        }
        
        guard targetLanguage.isSupported else {
            throw TranslationError.languageNotSupported
        }
        
        // Check for same language
        guard sourceLanguage != targetLanguage else {
            throw TranslationError.sameLanguage
        }
        
        // Validate text content
        guard !containsMaliciousContent(text) else {
            throw TranslationError.maliciousContent
        }
    }
    
    private func validateAudioData(_ audioData: Data) throws {
        guard !audioData.isEmpty else {
            throw TranslationError.emptyInput
        }
        
        guard audioData.count <= 10 * 1024 * 1024 else { // 10MB limit
            throw TranslationError.audioTooLarge
        }
    }
    
    private func determineTranslationStrategy(
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) -> TranslationStrategy {
        
        // Check if offline translation is available and preferred
        if let config = configuration,
           config.enableOfflineMode,
           isOfflineAvailable(from: sourceLanguage, to: targetLanguage) {
            return .offline
        }
        
        // Use online translation
        return .online
    }
    
    private func performTranslation(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language,
        strategy: TranslationStrategy
    ) async throws -> String {
        
        switch strategy {
        case .online:
            return try await networkService.translate(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
            
        case .offline:
            return try await offlineService.translateOffline(
                text: text,
                from: sourceLanguage,
                to: targetLanguage
            )
        }
    }
    
    private func synthesizeSpeech(
        text: String,
        language: Language
    ) async throws -> Data? {
        
        // Implementation for text-to-speech synthesis
        // This would integrate with AVSpeechSynthesizer or similar
        return nil
    }
    
    private func containsMaliciousContent(_ text: String) -> Bool {
        let maliciousPatterns = [
            "javascript:",
            "<script>",
            "SELECT *",
            "DROP TABLE",
            "UNION SELECT"
        ]
        
        return maliciousPatterns.contains { pattern in
            text.lowercased().contains(pattern.lowercased())
        }
    }
    
    private func setupPerformanceMonitoring() {
        performanceMonitor.enableMonitoring()
    }
    
    private func setupErrorHandling() {
        // Setup global error handling
    }
}

// MARK: - Supporting Types

public struct TranslationEngineConfiguration {
    public let defaultSourceLanguage: Language
    public let defaultTargetLanguage: Language
    public let enableOfflineMode: Bool
    public let enableCaching: Bool
    public let cacheSize: Int
    public let networkTimeout: TimeInterval
    public let enableEncryption: Bool
    
    public init(
        defaultSourceLanguage: Language = .english,
        defaultTargetLanguage: Language = .spanish,
        enableOfflineMode: Bool = true,
        enableCaching: Bool = true,
        cacheSize: Int = 1000,
        networkTimeout: TimeInterval = 30.0,
        enableEncryption: Bool = true
    ) {
        self.defaultSourceLanguage = defaultSourceLanguage
        self.defaultTargetLanguage = defaultTargetLanguage
        self.enableOfflineMode = enableOfflineMode
        self.enableCaching = enableCaching
        self.cacheSize = cacheSize
        self.networkTimeout = networkTimeout
        self.enableEncryption = enableEncryption
    }
}

public struct TranslationResult {
    public let originalText: String
    public let translatedText: String
    public let sourceLanguage: Language
    public let targetLanguage: Language
    public let timestamp: Date
    public let confidence: Float?
    public let processingTime: TimeInterval?
    
    public init(
        originalText: String,
        translatedText: String,
        sourceLanguage: Language,
        targetLanguage: Language,
        timestamp: Date = Date(),
        confidence: Float? = nil,
        processingTime: TimeInterval? = nil
    ) {
        self.originalText = originalText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.timestamp = timestamp
        self.confidence = confidence
        self.processingTime = processingTime
    }
}

public enum TranslationStrategy {
    case online
    case offline
}

public enum TranslationError: LocalizedError {
    case engineNotConfigured
    case emptyInput
    case inputTooLong
    case languageNotSupported
    case sameLanguage
    case maliciousContent
    case networkError
    case offlineNotAvailable
    case audioTooLarge
    case translationFailed
    
    public var errorDescription: String? {
        switch self {
        case .engineNotConfigured:
            return "Translation engine is not configured"
        case .emptyInput:
            return "Input text cannot be empty"
        case .inputTooLong:
            return "Input text is too long (maximum 5000 characters)"
        case .languageNotSupported:
            return "Language is not supported"
        case .sameLanguage:
            return "Source and target languages cannot be the same"
        case .maliciousContent:
            return "Input contains malicious content"
        case .networkError:
            return "Network connection failed"
        case .offlineNotAvailable:
            return "Offline translation is not available for this language pair"
        case .audioTooLarge:
            return "Audio file is too large (maximum 10MB)"
        case .translationFailed:
            return "Translation failed"
        }
    }
} 
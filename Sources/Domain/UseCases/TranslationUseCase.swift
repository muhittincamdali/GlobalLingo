import Foundation

/// Protocol defining the translation use case operations
public protocol TranslationUseCaseProtocol {
    
    /// Translate text from one language to another
    /// - Parameters:
    ///   - text: Text to translate
    ///   - sourceLanguage: Source language
    ///   - targetLanguage: Target language
    ///   - quality: Translation quality level
    /// - Returns: Translation result
    func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language,
        quality: TranslationQuality
    ) async throws -> TranslationResult
    
    /// Batch translate multiple texts
    /// - Parameters:
    ///   - texts: Array of texts to translate
    ///   - sourceLanguage: Source language
    ///   - targetLanguage: Target language
    ///   - quality: Translation quality level
    /// - Returns: Array of translation results
    func batchTranslate(
        texts: [String],
        from sourceLanguage: Language,
        to targetLanguage: Language,
        quality: TranslationQuality
    ) async throws -> [TranslationResult]
    
    /// Translate text with context
    /// - Parameters:
    ///   - text: Text to translate
    ///   - context: Translation context
    ///   - sourceLanguage: Source language
    ///   - targetLanguage: Target language
    ///   - quality: Translation quality level
    /// - Returns: Translation result with context
    func translateWithContext(
        text: String,
        context: String,
        from sourceLanguage: Language,
        to targetLanguage: Language,
        quality: TranslationQuality
    ) async throws -> ContextualTranslationResult
}

/// Implementation of the translation use case
public class TranslationUseCase: TranslationUseCaseProtocol {
    
    // MARK: - Dependencies
    
    private let translationEngine: TranslationEngineProtocol
    private let cacheManager: CacheManagerProtocol
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Initialization
    
    /// Initialize the translation use case
    /// - Parameters:
    ///   - translationEngine: Translation engine
    ///   - cacheManager: Cache manager
    ///   - networkService: Network service
    public init(
        translationEngine: TranslationEngineProtocol,
        cacheManager: CacheManagerProtocol,
        networkService: NetworkServiceProtocol
    ) {
        self.translationEngine = translationEngine
        self.cacheManager = cacheManager
        self.networkService = networkService
    }
    
    // MARK: - TranslationUseCaseProtocol Implementation
    
    public func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language,
        quality: TranslationQuality
    ) async throws -> TranslationResult {
        
        // Check cache first
        let cacheKey = generateCacheKey(text: text, from: sourceLanguage, to: targetLanguage, quality: quality)
        if let cachedResult = await cacheManager.get(for: cacheKey) as? TranslationResult {
            return cachedResult
        }
        
        // Perform translation
        let result = try await translationEngine.translate(
            text: text,
            from: sourceLanguage,
            to: targetLanguage,
            quality: quality
        )
        
        // Cache result
        await cacheManager.set(result, for: cacheKey)
        
        return result
    }
    
    public func batchTranslate(
        texts: [String],
        from sourceLanguage: Language,
        to targetLanguage: Language,
        quality: TranslationQuality
    ) async throws -> [TranslationResult] {
        
        var results: [TranslationResult] = []
        
        for text in texts {
            let result = try await translate(
                text: text,
                from: sourceLanguage,
                to: targetLanguage,
                quality: quality
            )
            results.append(result)
        }
        
        return results
    }
    
    public func translateWithContext(
        text: String,
        context: String,
        from sourceLanguage: Language,
        to targetLanguage: Language,
        quality: TranslationQuality
    ) async throws -> ContextualTranslationResult {
        
        // Check cache first
        let cacheKey = generateContextualCacheKey(
            text: text,
            context: context,
            from: sourceLanguage,
            to: targetLanguage,
            quality: quality
        )
        
        if let cachedResult = await cacheManager.get(for: cacheKey) as? ContextualTranslationResult {
            return cachedResult
        }
        
        // Perform contextual translation
        let result = try await translationEngine.translateWithContext(
            text: text,
            context: context,
            from: sourceLanguage,
            to: targetLanguage,
            quality: quality
        )
        
        // Cache result
        await cacheManager.set(result, for: cacheKey)
        
        return result
    }
    
    // MARK: - Private Methods
    
    private func generateCacheKey(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language,
        quality: TranslationQuality
    ) -> String {
        return "translation_\(sourceLanguage.code)_\(targetLanguage.code)_\(quality.rawValue)_\(text.hashValue)"
    }
    
    private func generateContextualCacheKey(
        text: String,
        context: String,
        from sourceLanguage: Language,
        to targetLanguage: Language,
        quality: TranslationQuality
    ) -> String {
        return "contextual_translation_\(sourceLanguage.code)_\(targetLanguage.code)_\(quality.rawValue)_\(text.hashValue)_\(context.hashValue)"
    }
}

// MARK: - Translation Quality

/// Represents translation quality levels
public enum TranslationQuality: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case premium = "premium"
}

// MARK: - Translation Result

/// Represents a translation result
public struct TranslationResult: Codable {
    public let originalText: String
    public let translatedText: String
    public let sourceLanguage: Language
    public let targetLanguage: Language
    public let quality: TranslationQuality
    public let confidence: Double
    public let timestamp: Date
    public let metadata: [String: Any]
    
    public init(
        originalText: String,
        translatedText: String,
        sourceLanguage: Language,
        targetLanguage: Language,
        quality: TranslationQuality,
        confidence: Double,
        timestamp: Date = Date(),
        metadata: [String: Any] = [:]
    ) {
        self.originalText = originalText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.quality = quality
        self.confidence = confidence
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

// MARK: - Contextual Translation Result

/// Represents a contextual translation result
public struct ContextualTranslationResult: Codable {
    public let originalText: String
    public let translatedText: String
    public let context: String
    public let sourceLanguage: Language
    public let targetLanguage: Language
    public let quality: TranslationQuality
    public let confidence: Double
    public let contextRelevance: Double
    public let timestamp: Date
    public let metadata: [String: Any]
    
    public init(
        originalText: String,
        translatedText: String,
        context: String,
        sourceLanguage: Language,
        targetLanguage: Language,
        quality: TranslationQuality,
        confidence: Double,
        contextRelevance: Double,
        timestamp: Date = Date(),
        metadata: [String: Any] = [:]
    ) {
        self.originalText = originalText
        self.translatedText = translatedText
        self.context = context
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.quality = quality
        self.confidence = confidence
        self.contextRelevance = contextRelevance
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

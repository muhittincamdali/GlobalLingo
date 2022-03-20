import Foundation

/// Result of voice translation operation
/// Contains original text, translated text, audio data, and metadata
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public struct VoiceTranslationResult {
    
    // MARK: - Properties
    
    /// Original text from voice recognition
    public let originalText: String
    
    /// Translated text
    public let translatedText: String
    
    /// Synthesized audio data (optional)
    public let audioData: Data?
    
    /// Confidence level of the translation (0.0 to 1.0)
    public let confidence: Float
    
    /// Target language of the translation
    public let language: Language
    
    /// Processing time in seconds
    public let processingTime: TimeInterval
    
    /// Timestamp of the translation
    public let timestamp: Date
    
    // MARK: - Initialization
    
    public init(
        originalText: String,
        translatedText: String,
        audioData: Data? = nil,
        confidence: Float,
        language: Language,
        processingTime: TimeInterval = 0.0,
        timestamp: Date = Date()
    ) {
        self.originalText = originalText
        self.translatedText = translatedText
        self.audioData = audioData
        self.confidence = confidence
        self.language = language
        self.processingTime = processingTime
        self.timestamp = timestamp
    }
    
    // MARK: - Computed Properties
    
    /// Whether the translation has audio data
    public var hasAudio: Bool {
        return audioData != nil
    }
    
    /// Whether the confidence is high enough
    public var isHighConfidence: Bool {
        return confidence >= 0.8
    }
    
    /// Whether the confidence is acceptable
    public var isAcceptableConfidence: Bool {
        return confidence >= 0.6
    }
    
    /// Formatted processing time
    public var formattedProcessingTime: String {
        return String(format: "%.2fs", processingTime)
    }
    
    /// Formatted confidence percentage
    public var formattedConfidence: String {
        return String(format: "%.1f%%", confidence * 100)
    }
} 
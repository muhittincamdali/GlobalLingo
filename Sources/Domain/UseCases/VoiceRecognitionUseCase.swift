import Foundation
import Speech

/// Protocol defining voice recognition use case operations
public protocol VoiceRecognitionUseCaseProtocol {
    
    /// Check if voice recognition is available
    /// - Returns: True if voice recognition is available
    func isVoiceRecognitionAvailable() async -> Bool
    
    /// Request voice recognition permissions
    /// - Returns: True if permissions granted
    func requestVoiceRecognitionPermissions() async -> Bool
    
    /// Start voice recognition
    /// - Parameters:
    ///   - language: Language for recognition
    ///   - resultHandler: Handler for recognition results
    ///   - errorHandler: Handler for errors
    /// - Returns: True if started successfully
    func startVoiceRecognition(
        language: Language,
        resultHandler: @escaping (VoiceRecognitionResult) -> Void,
        errorHandler: @escaping (VoiceRecognitionError) -> Void
    ) async throws -> Bool
    
    /// Stop voice recognition
    /// - Returns: True if stopped successfully
    func stopVoiceRecognition() async throws -> Bool
    
    /// Recognize speech from audio file
    /// - Parameters:
    ///   - audioURL: URL of audio file
    ///   - language: Language for recognition
    /// - Returns: Recognition result
    func recognizeSpeechFromFile(
        audioURL: URL,
        language: Language
    ) async throws -> VoiceRecognitionResult
    
    /// Get supported languages for voice recognition
    /// - Returns: Array of supported languages
    func getSupportedLanguages() async -> [Language]
    
    /// Check if language is supported for voice recognition
    /// - Parameter language: Language to check
    /// - Returns: True if supported
    func isLanguageSupported(_ language: Language) async -> Bool
}

/// Implementation of the voice recognition use case
public class VoiceRecognitionUseCase: VoiceRecognitionUseCaseProtocol {
    
    // MARK: - Dependencies
    
    private let voiceRecognitionService: VoiceRecognitionServiceProtocol
    private let permissionManager: PermissionManagerProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    // MARK: - Initialization
    
    /// Initialize the voice recognition use case
    /// - Parameters:
    ///   - voiceRecognitionService: Voice recognition service
    ///   - permissionManager: Permission manager
    ///   - analyticsService: Analytics service
    public init(
        voiceRecognitionService: VoiceRecognitionServiceProtocol,
        permissionManager: PermissionManagerProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.voiceRecognitionService = voiceRecognitionService
        self.permissionManager = permissionManager
        self.analyticsService = analyticsService
    }
    
    // MARK: - VoiceRecognitionUseCaseProtocol Implementation
    
    public func isVoiceRecognitionAvailable() async -> Bool {
        return await voiceRecognitionService.isAvailable()
    }
    
    public func requestVoiceRecognitionPermissions() async -> Bool {
        
        // Track permission request
        await analyticsService.trackEvent(.voiceRecognitionPermissionRequested)
        
        // Request permissions
        let granted = await permissionManager.requestSpeechRecognitionPermission()
        
        // Track permission result
        await analyticsService.trackEvent(.voiceRecognitionPermissionResult, properties: [
            "granted": granted
        ])
        
        return granted
    }
    
    public func startVoiceRecognition(
        language: Language,
        resultHandler: @escaping (VoiceRecognitionResult) -> Void,
        errorHandler: @escaping (VoiceRecognitionError) -> Void
    ) async throws -> Bool {
        
        // Check permissions
        guard await permissionManager.hasSpeechRecognitionPermission() else {
            throw VoiceRecognitionError.permissionDenied
        }
        
        // Check if language is supported
        guard await isLanguageSupported(language) else {
            throw VoiceRecognitionError.languageNotSupported(language)
        }
        
        // Track recognition start
        await analyticsService.trackEvent(.voiceRecognitionStarted, properties: [
            "language": language.code
        ])
        
        // Start recognition
        return try await voiceRecognitionService.startRecognition(
            language: language,
            resultHandler: resultHandler,
            errorHandler: errorHandler
        )
    }
    
    public func stopVoiceRecognition() async throws -> Bool {
        
        // Track recognition stop
        await analyticsService.trackEvent(.voiceRecognitionStopped)
        
        // Stop recognition
        return try await voiceRecognitionService.stopRecognition()
    }
    
    public func recognizeSpeechFromFile(
        audioURL: URL,
        language: Language
    ) async throws -> VoiceRecognitionResult {
        
        // Check if language is supported
        guard await isLanguageSupported(language) else {
            throw VoiceRecognitionError.languageNotSupported(language)
        }
        
        // Track file recognition
        await analyticsService.trackEvent(.voiceRecognitionFromFile, properties: [
            "language": language.code
        ])
        
        // Recognize speech from file
        return try await voiceRecognitionService.recognizeFromFile(
            audioURL: audioURL,
            language: language
        )
    }
    
    public func getSupportedLanguages() async -> [Language] {
        return await voiceRecognitionService.getSupportedLanguages()
    }
    
    public func isLanguageSupported(_ language: Language) async -> Bool {
        let supportedLanguages = await getSupportedLanguages()
        return supportedLanguages.contains(language)
    }
}

// MARK: - Voice Recognition Result

/// Represents a voice recognition result
public struct VoiceRecognitionResult: Codable {
    public let text: String
    public let confidence: Double
    public let language: Language
    public let timestamp: Date
    public let duration: TimeInterval
    public let isFinal: Bool
    public let alternatives: [String]
    
    public init(
        text: String,
        confidence: Double,
        language: Language,
        timestamp: Date = Date(),
        duration: TimeInterval = 0,
        isFinal: Bool = false,
        alternatives: [String] = []
    ) {
        self.text = text
        self.confidence = confidence
        self.language = language
        self.timestamp = timestamp
        self.duration = duration
        self.isFinal = isFinal
        self.alternatives = alternatives
    }
}

// MARK: - Voice Recognition Error

/// Errors that can occur during voice recognition
public enum VoiceRecognitionError: Error, LocalizedError {
    case permissionDenied
    case languageNotSupported(Language)
    case audioEngineNotAvailable
    case recognitionNotAvailable
    case audioSessionError(String)
    case recognitionError(String)
    case fileNotFound
    case invalidAudioFormat
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Speech recognition permission denied"
        case .languageNotSupported(let language):
            return "Language \(language.name) is not supported for voice recognition"
        case .audioEngineNotAvailable:
            return "Audio engine is not available"
        case .recognitionNotAvailable:
            return "Speech recognition is not available"
        case .audioSessionError(let message):
            return "Audio session error: \(message)"
        case .recognitionError(let message):
            return "Recognition error: \(message)"
        case .fileNotFound:
            return "Audio file not found"
        case .invalidAudioFormat:
            return "Invalid audio format"
        }
    }
}

// MARK: - Permission Manager Protocol

/// Protocol for permission management operations
public protocol PermissionManagerProtocol {
    
    /// Request speech recognition permission
    /// - Returns: True if permission granted
    func requestSpeechRecognitionPermission() async -> Bool
    
    /// Check if speech recognition permission is granted
    /// - Returns: True if permission granted
    func hasSpeechRecognitionPermission() async -> Bool
    
    /// Request microphone permission
    /// - Returns: True if permission granted
    func requestMicrophonePermission() async -> Bool
    
    /// Check if microphone permission is granted
    /// - Returns: True if permission granted
    func hasMicrophonePermission() async -> Bool
}

// MARK: - Voice Recognition Service Protocol

/// Protocol for voice recognition service operations
public protocol VoiceRecognitionServiceProtocol {
    
    /// Check if voice recognition is available
    /// - Returns: True if available
    func isAvailable() async -> Bool
    
    /// Start voice recognition
    /// - Parameters:
    ///   - language: Language for recognition
    ///   - resultHandler: Handler for results
    ///   - errorHandler: Handler for errors
    /// - Returns: True if started successfully
    func startRecognition(
        language: Language,
        resultHandler: @escaping (VoiceRecognitionResult) -> Void,
        errorHandler: @escaping (VoiceRecognitionError) -> Void
    ) async throws -> Bool
    
    /// Stop voice recognition
    /// - Returns: True if stopped successfully
    func stopRecognition() async throws -> Bool
    
    /// Recognize speech from file
    /// - Parameters:
    ///   - audioURL: URL of audio file
    ///   - language: Language for recognition
    /// - Returns: Recognition result
    func recognizeFromFile(
        audioURL: URL,
        language: Language
    ) async throws -> VoiceRecognitionResult
    
    /// Get supported languages
    /// - Returns: Array of supported languages
    func getSupportedLanguages() async -> [Language]
}

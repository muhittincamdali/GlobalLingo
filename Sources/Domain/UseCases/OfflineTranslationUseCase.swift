import Foundation

/// Protocol defining offline translation use case operations
public protocol OfflineTranslationUseCaseProtocol {
    
    /// Check if offline translation is available for the given language pair
    /// - Parameters:
    ///   - sourceLanguage: Source language
    ///   - targetLanguage: Target language
    /// - Returns: True if offline translation is available
    func isOfflineTranslationAvailable(
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async -> Bool
    
    /// Download offline translation model
    /// - Parameters:
    ///   - sourceLanguage: Source language
    ///   - targetLanguage: Target language
    ///   - progressHandler: Progress handler
    /// - Returns: True if download successful
    func downloadOfflineModel(
        from sourceLanguage: Language,
        to targetLanguage: Language,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> Bool
    
    /// Translate text offline
    /// - Parameters:
    ///   - text: Text to translate
    ///   - sourceLanguage: Source language
    ///   - targetLanguage: Target language
    /// - Returns: Translation result
    func translateOffline(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> TranslationResult
    
    /// Get available offline models
    /// - Returns: Array of available language pairs
    func getAvailableOfflineModels() async -> [LanguagePair]
    
    /// Delete offline model
    /// - Parameters:
    ///   - sourceLanguage: Source language
    ///   - targetLanguage: Target language
    /// - Returns: True if deletion successful
    func deleteOfflineModel(
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> Bool
}

/// Implementation of the offline translation use case
public class OfflineTranslationUseCase: OfflineTranslationUseCaseProtocol {
    
    // MARK: - Dependencies
    
    private let offlineService: OfflineServiceProtocol
    private let storageManager: StorageManagerProtocol
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Initialization
    
    /// Initialize the offline translation use case
    /// - Parameters:
    ///   - offlineService: Offline service
    ///   - storageManager: Storage manager
    ///   - networkService: Network service
    public init(
        offlineService: OfflineServiceProtocol,
        storageManager: StorageManagerProtocol,
        networkService: NetworkServiceProtocol
    ) {
        self.offlineService = offlineService
        self.storageManager = storageManager
        self.networkService = networkService
    }
    
    // MARK: - OfflineTranslationUseCaseProtocol Implementation
    
    public func isOfflineTranslationAvailable(
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async -> Bool {
        return await offlineService.isModelAvailable(
            from: sourceLanguage,
            to: targetLanguage
        )
    }
    
    public func downloadOfflineModel(
        from sourceLanguage: Language,
        to targetLanguage: Language,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> Bool {
        
        // Check if model already exists
        if await isOfflineTranslationAvailable(from: sourceLanguage, to: targetLanguage) {
            return true
        }
        
        // Check available storage space
        let requiredSpace = await offlineService.getRequiredStorageSpace(
            from: sourceLanguage,
            to: targetLanguage
        )
        
        let availableSpace = await storageManager.getAvailableStorageSpace()
        
        guard availableSpace >= requiredSpace else {
            throw OfflineTranslationError.insufficientStorageSpace(
                required: requiredSpace,
                available: availableSpace
            )
        }
        
        // Download model
        return try await offlineService.downloadModel(
            from: sourceLanguage,
            to: targetLanguage,
            progressHandler: progressHandler
        )
    }
    
    public func translateOffline(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> TranslationResult {
        
        // Check if offline model is available
        guard await isOfflineTranslationAvailable(from: sourceLanguage, to: targetLanguage) else {
            throw OfflineTranslationError.modelNotAvailable(
                from: sourceLanguage,
                to: targetLanguage
            )
        }
        
        // Perform offline translation
        return try await offlineService.translate(
            text: text,
            from: sourceLanguage,
            to: targetLanguage
        )
    }
    
    public func getAvailableOfflineModels() async -> [LanguagePair] {
        return await offlineService.getAvailableModels()
    }
    
    public func deleteOfflineModel(
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> Bool {
        
        // Check if model exists
        guard await isOfflineTranslationAvailable(from: sourceLanguage, to: targetLanguage) else {
            throw OfflineTranslationError.modelNotAvailable(
                from: sourceLanguage,
                to: targetLanguage
            )
        }
        
        // Delete model
        return try await offlineService.deleteModel(
            from: sourceLanguage,
            to: targetLanguage
        )
    }
}

// MARK: - Language Pair

/// Represents a language pair for translation
public struct LanguagePair: Codable, Hashable {
    public let sourceLanguage: Language
    public let targetLanguage: Language
    public let modelSize: Int64
    public let downloadDate: Date
    public let version: String
    
    public init(
        sourceLanguage: Language,
        targetLanguage: Language,
        modelSize: Int64,
        downloadDate: Date,
        version: String
    ) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.modelSize = modelSize
        self.downloadDate = downloadDate
        self.version = version
    }
}

// MARK: - Offline Translation Error

/// Errors that can occur during offline translation
public enum OfflineTranslationError: Error, LocalizedError {
    case modelNotAvailable(from: Language, to: Language)
    case insufficientStorageSpace(required: Int64, available: Int64)
    case downloadFailed(String)
    case translationFailed(String)
    case modelCorrupted(String)
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .modelNotAvailable(let from, let to):
            return "Offline translation model not available for \(from.name) to \(to.name)"
        case .insufficientStorageSpace(let required, let available):
            return "Insufficient storage space. Required: \(required) bytes, Available: \(available) bytes"
        case .downloadFailed(let message):
            return "Model download failed: \(message)"
        case .translationFailed(let message):
            return "Offline translation failed: \(message)"
        case .modelCorrupted(let message):
            return "Model is corrupted: \(message)"
        case .networkUnavailable:
            return "Network is unavailable for model download"
        }
    }
}

// MARK: - Storage Manager Protocol

/// Protocol for storage management operations
public protocol StorageManagerProtocol {
    
    /// Get available storage space in bytes
    /// - Returns: Available storage space
    func getAvailableStorageSpace() async -> Int64
    
    /// Get used storage space in bytes
    /// - Returns: Used storage space
    func getUsedStorageSpace() async -> Int64
    
    /// Get total storage space in bytes
    /// - Returns: Total storage space
    func getTotalStorageSpace() async -> Int64
    
    /// Clear all cached data
    /// - Returns: True if successful
    func clearCache() async throws -> Bool
}

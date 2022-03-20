import Foundation
import Crypto

/// Offline service for GlobalLingo translation framework
/// Handles offline translation, model management, and local processing
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public class OfflineService {
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let modelsDirectory: URL
    private var isOfflineEnabled = false
    
    private var downloadedModels: Set<String> = []
    private var modelCache: [String: OfflineModel] = [:]
    
    // MARK: - Initialization
    
    public init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        modelsDirectory = documentsPath.appendingPathComponent("GlobalLingoModels")
        
        createModelsDirectoryIfNeeded()
        loadDownloadedModels()
    }
    
    // MARK: - Configuration
    
    /// Configure offline service
    /// - Parameter enableOffline: Whether offline mode is enabled
    public func configure(enableOffline: Bool) {
        self.isOfflineEnabled = enableOffline
    }
    
    // MARK: - Offline Translation
    
    /// Check if offline translation is available for language pair
    /// - Parameters:
    ///   - from: Source language
    ///   - to: Target language
    /// - Returns: Boolean indicating offline availability
    public func isOfflineAvailable(from sourceLanguage: Language, to targetLanguage: Language) -> Bool {
        guard isOfflineEnabled else { return false }
        
        let modelKey = "\(sourceLanguage.code)_\(targetLanguage.code)"
        return downloadedModels.contains(modelKey)
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
        
        guard isOfflineAvailable(from: sourceLanguage, to: targetLanguage) else {
            throw OfflineError.modelNotAvailable
        }
        
        let modelKey = "\(sourceLanguage.code)_\(targetLanguage.code)"
        
        // Load model if not in cache
        if modelCache[modelKey] == nil {
            try await loadModel(for: modelKey)
        }
        
        guard let model = modelCache[modelKey] else {
            throw OfflineError.modelLoadFailed
        }
        
        // Perform offline translation
        return try await performOfflineTranslation(
            text: text,
            model: model
        )
    }
    
    /// Download language model for offline use
    /// - Parameter language: Language for the model
    /// - Returns: Boolean indicating success
    public func downloadLanguageModel(for language: Language) async throws -> Bool {
        
        let modelKey = "\(language.code)_en" // Default to English as target
        
        guard !downloadedModels.contains(modelKey) else {
            return true // Already downloaded
        }
        
        do {
            // In a real implementation, this would download from a server
            // For now, we'll create a mock model
            let model = createMockModel(for: language)
            
            // Save model to disk
            try saveModelToDisk(model: model, key: modelKey)
            
            // Add to downloaded models
            downloadedModels.insert(modelKey)
            modelCache[modelKey] = model
            
            // Save downloaded models list
            saveDownloadedModelsList()
            
            return true
            
        } catch {
            throw OfflineError.downloadFailed(error)
        }
    }
    
    /// Get downloaded languages
    /// - Returns: Array of downloaded languages
    public func getDownloadedLanguages() -> [Language] {
        return downloadedModels.compactMap { modelKey in
            let components = modelKey.split(separator: "_")
            guard components.count >= 2 else { return nil }
            
            let sourceCode = String(components[0])
            return Language.byCode(sourceCode)
        }
    }
    
    /// Remove language model
    /// - Parameter language: Language to remove model for
    public func removeLanguageModel(for language: Language) async throws {
        
        let modelKey = "\(language.code)_en"
        
        guard downloadedModels.contains(modelKey) else {
            throw OfflineError.modelNotDownloaded
        }
        
        // Remove from disk
        try removeModelFromDisk(key: modelKey)
        
        // Remove from memory
        downloadedModels.remove(modelKey)
        modelCache.removeValue(forKey: modelKey)
        
        // Save updated list
        saveDownloadedModelsList()
    }
    
    /// Get offline model statistics
    /// - Returns: OfflineModelStatistics object
    public func getModelStatistics() -> OfflineModelStatistics {
        let totalSize = calculateTotalModelSize()
        let availableSpace = getAvailableDiskSpace()
        
        return OfflineModelStatistics(
            downloadedModels: downloadedModels.count,
            totalSize: totalSize,
            availableSpace: availableSpace,
            languages: getDownloadedLanguages()
        )
    }
    
    // MARK: - Private Methods
    
    private func createModelsDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: modelsDirectory.path) {
            try? fileManager.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func loadDownloadedModels() {
        let listURL = modelsDirectory.appendingPathComponent("downloaded_models.json")
        
        guard let data = try? Data(contentsOf: listURL),
              let models = try? JSONDecoder().decode([String].self, from: data) else {
            return
        }
        
        downloadedModels = Set(models)
    }
    
    private func saveDownloadedModelsList() {
        let listURL = modelsDirectory.appendingPathComponent("downloaded_models.json")
        let data = try? JSONEncoder().encode(Array(downloadedModels))
        try? data?.write(to: listURL)
    }
    
    private func loadModel(for key: String) async throws {
        let modelURL = modelsDirectory.appendingPathComponent("\(key).model")
        
        guard let data = try? Data(contentsOf: modelURL) else {
            throw OfflineError.modelLoadFailed
        }
        
        do {
            let model = try JSONDecoder().decode(OfflineModel.self, from: data)
            modelCache[key] = model
        } catch {
            throw OfflineError.modelLoadFailed
        }
    }
    
    private func saveModelToDisk(model: OfflineModel, key: String) throws {
        let modelURL = modelsDirectory.appendingPathComponent("\(key).model")
        let data = try JSONEncoder().encode(model)
        try data.write(to: modelURL)
    }
    
    private func removeModelFromDisk(key: String) throws {
        let modelURL = modelsDirectory.appendingPathComponent("\(key).model")
        
        if fileManager.fileExists(atPath: modelURL.path) {
            try fileManager.removeItem(at: modelURL)
        }
    }
    
    private func createMockModel(for language: Language) -> OfflineModel {
        // In a real implementation, this would be a proper ML model
        // For now, we'll create a mock model with basic translation rules
        
        let translationRules: [String: String] = [
            "hello": "hola",
            "goodbye": "adiós",
            "thank you": "gracias",
            "please": "por favor",
            "sorry": "lo siento",
            "yes": "sí",
            "no": "no",
            "good": "bueno",
            "bad": "malo",
            "big": "grande",
            "small": "pequeño"
        ]
        
        return OfflineModel(
            id: "\(language.code)_en",
            sourceLanguage: language.code,
            targetLanguage: "en",
            version: "1.0.0",
            size: 1024 * 1024, // 1MB
            translationRules: translationRules,
            confidence: 0.85
        )
    }
    
    private func performOfflineTranslation(
        text: String,
        model: OfflineModel
    ) async throws -> String {
        
        // Simple word-by-word translation using rules
        let words = text.lowercased().split(separator: " ")
        var translatedWords: [String] = []
        
        for word in words {
            let cleanWord = String(word).trimmingCharacters(in: .punctuationCharacters)
            
            if let translation = model.translationRules[cleanWord] {
                translatedWords.append(translation)
            } else {
                // If no direct translation, keep original word
                translatedWords.append(String(word))
            }
        }
        
        return translatedWords.joined(separator: " ")
    }
    
    private func calculateTotalModelSize() -> Int64 {
        var totalSize: Int64 = 0
        
        for modelKey in downloadedModels {
            let modelURL = modelsDirectory.appendingPathComponent("\(modelKey).model")
            
            if let attributes = try? fileManager.attributesOfItem(atPath: modelURL.path),
               let size = attributes[.size] as? Int64 {
                totalSize += size
            }
        }
        
        return totalSize
    }
    
    private func getAvailableDiskSpace() -> Int64 {
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: modelsDirectory.path)
            return attributes[.systemFreeSize] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
}

// MARK: - Supporting Types

public struct OfflineModel: Codable {
    public let id: String
    public let sourceLanguage: String
    public let targetLanguage: String
    public let version: String
    public let size: Int64
    public let translationRules: [String: String]
    public let confidence: Float
    
    public init(
        id: String,
        sourceLanguage: String,
        targetLanguage: String,
        version: String,
        size: Int64,
        translationRules: [String: String],
        confidence: Float
    ) {
        self.id = id
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.version = version
        self.size = size
        self.translationRules = translationRules
        self.confidence = confidence
    }
}

public struct OfflineModelStatistics {
    public let downloadedModels: Int
    public let totalSize: Int64
    public let availableSpace: Int64
    public let languages: [Language]
    
    public init(
        downloadedModels: Int,
        totalSize: Int64,
        availableSpace: Int64,
        languages: [Language]
    ) {
        self.downloadedModels = downloadedModels
        self.totalSize = totalSize
        self.availableSpace = availableSpace
        self.languages = languages
    }
    
    public var totalSizeInMB: Double {
        return Double(totalSize) / (1024 * 1024)
    }
    
    public var availableSpaceInMB: Double {
        return Double(availableSpace) / (1024 * 1024)
    }
    
    public var canDownloadMore: Bool {
        return availableSpace > totalSize * 2 // Require 2x space for safety
    }
}

public enum OfflineError: LocalizedError {
    case modelNotAvailable
    case modelLoadFailed
    case modelNotDownloaded
    case downloadFailed(Error)
    case insufficientSpace
    case invalidModel
    
    public var errorDescription: String? {
        switch self {
        case .modelNotAvailable:
            return "Offline model is not available for this language pair"
        case .modelLoadFailed:
            return "Failed to load offline model"
        case .modelNotDownloaded:
            return "Model is not downloaded"
        case .downloadFailed(let error):
            return "Failed to download model: \(error.localizedDescription)"
        case .insufficientSpace:
            return "Insufficient disk space to download model"
        case .invalidModel:
            return "Invalid model format"
        }
    }
} 
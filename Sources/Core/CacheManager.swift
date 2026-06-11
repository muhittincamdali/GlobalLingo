import Foundation
import CryptoKit

/// Cache manager for GlobalLingo translation framework
/// Handles caching of translations, language models, and other data
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public actor CacheManager {
    
    // MARK: - Properties
    
    private var memoryCache: [String: CachedItem] = [:]
    private var maxCacheSize: Int = 1000
    private var currentCacheSize: Int = 0
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // MARK: - Initialization
    
    public init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("GlobalLingoCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Cache Operations
    
    public func cacheTranslation(
        text: String,
        result: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) {
        let key = generateCacheKey(text: text, from: sourceLanguage, to: targetLanguage)
        let item = CachedItem(
            key: key,
            value: result,
            timestamp: Date(),
            type: .translation,
            metadata: [:]
        )
        
        memoryCache[key] = item
        currentCacheSize += 1
        saveItemToDisk(item)
    }
    
    public func getCachedTranslation(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) -> String? {
        let key = generateCacheKey(text: text, from: sourceLanguage, to: targetLanguage)
        
        if let item = memoryCache[key], !item.isExpired {
            return item.value
        }
        
        if let item = loadItemFromDisk(key: key), !item.isExpired {
            memoryCache[key] = item
            return item.value
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func generateCacheKey(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) -> String {
        let combined = "\(sourceLanguage.code)_\(targetLanguage.code)_\(text)"
        let data = Data(combined.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func saveItemToDisk(_ item: CachedItem) {
        let fileURL = cacheDirectory.appendingPathComponent("\(item.key).cache")
        do {
            let data = try JSONEncoder().encode(item)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save cache item: \(error)")
        }
    }
    
    private func loadItemFromDisk(key: String) -> CachedItem? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).cache")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(CachedItem.self, from: data)
    }
}

// MARK: - Supporting Types

public struct CachedItem: Codable, Sendable {
    public let key: String
    public let value: String
    public let timestamp: Date
    public let type: CacheItemType
    public let metadata: [String: String]
    
    public var isExpired: Bool {
        let expirationInterval: TimeInterval = 24 * 60 * 60 // 24 hours
        return Date().timeIntervalSince(timestamp) > expirationInterval
    }
}

public enum CacheItemType: String, Codable, CaseIterable, Sendable {
    case translation
    case languageModel
    case voiceRecognition
    case other
}

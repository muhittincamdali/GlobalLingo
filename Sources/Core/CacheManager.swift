import Foundation
import Crypto

/// Cache manager for GlobalLingo translation framework
/// Handles caching of translations, language models, and other data
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public class CacheManager {
    
    // MARK: - Properties
    
    private var memoryCache: [String: CachedItem] = [:]
    private var maxCacheSize: Int = 1000
    private var currentCacheSize: Int = 0
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // MARK: - Initialization
    
    public init() {
        // Create cache directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("GlobalLingoCache")
        
        createCacheDirectoryIfNeeded()
        loadCacheFromDisk()
    }
    
    // MARK: - Configuration
    
    /// Configure cache manager
    /// - Parameter cacheSize: Maximum number of items in cache
    public func configure(cacheSize: Int) {
        self.maxCacheSize = cacheSize
        cleanupCacheIfNeeded()
    }
    
    // MARK: - Cache Operations
    
    /// Cache a translation result
    /// - Parameters:
    ///   - text: Original text
    ///   - result: Translation result
    ///   - from: Source language
    ///   - to: Target language
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
            metadata: [
                "sourceLanguage": sourceLanguage.code,
                "targetLanguage": targetLanguage.code,
                "textLength": String(text.count)
            ]
        )
        
        cacheItem(item)
    }
    
    /// Get cached translation
    /// - Parameters:
    ///   - text: Original text
    ///   - from: Source language
    ///   - to: Target language
    /// - Returns: Cached translation result if available
    public func getCachedTranslation(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) -> String? {
        let key = generateCacheKey(text: text, from: sourceLanguage, to: targetLanguage)
        
        // Check memory cache first
        if let item = memoryCache[key], !item.isExpired {
            return item.value
        }
        
        // Check disk cache
        if let item = loadItemFromDisk(key: key), !item.isExpired {
            // Move to memory cache
            memoryCache[key] = item
            return item.value
        }
        
        return nil
    }
    
    /// Cache language model
    /// - Parameters:
    ///   - language: Language for the model
    ///   - modelData: Model data
    public func cacheLanguageModel(
        language: Language,
        modelData: Data
    ) {
        let key = "model_\(language.code)"
        let item = CachedItem(
            key: key,
            value: String(data: modelData, encoding: .utf8) ?? "",
            timestamp: Date(),
            type: .languageModel,
            metadata: [
                "language": language.code,
                "modelSize": String(modelData.count)
            ]
        )
        
        cacheItem(item)
        saveModelToDisk(key: key, data: modelData)
    }
    
    /// Get cached language model
    /// - Parameter language: Language for the model
    /// - Returns: Cached model data if available
    public func getCachedLanguageModel(language: Language) -> Data? {
        let key = "model_\(language.code)"
        
        // Check memory cache first
        if let item = memoryCache[key], !item.isExpired {
            return item.value.data(using: .utf8)
        }
        
        // Check disk cache
        return loadModelFromDisk(key: key)
    }
    
    /// Cache voice recognition result
    /// - Parameters:
    ///   - audioHash: Hash of audio data
    ///   - result: Recognition result
    ///   - language: Language for recognition
    public func cacheVoiceRecognition(
        audioHash: String,
        result: String,
        language: Language
    ) {
        let key = "voice_\(audioHash)"
        let item = CachedItem(
            key: key,
            value: result,
            timestamp: Date(),
            type: .voiceRecognition,
            metadata: [
                "language": language.code,
                "audioHash": audioHash
            ]
        )
        
        cacheItem(item)
    }
    
    /// Get cached voice recognition result
    /// - Parameters:
    ///   - audioHash: Hash of audio data
    ///   - language: Language for recognition
    /// - Returns: Cached recognition result if available
    public func getCachedVoiceRecognition(
        audioHash: String,
        language: Language
    ) -> String? {
        let key = "voice_\(audioHash)"
        
        if let item = memoryCache[key], !item.isExpired {
            return item.value
        }
        
        return nil
    }
    
    /// Clear all cache
    public func clearCache() {
        memoryCache.removeAll()
        currentCacheSize = 0
        
        // Clear disk cache
        clearDiskCache()
        
        // Save empty cache state
        saveCacheToDisk()
    }
    
    /// Clear cache for specific language
    /// - Parameter language: Language to clear cache for
    public func clearCacheForLanguage(_ language: Language) {
        let languagePrefix = "\(language.code)_"
        
        // Remove from memory cache
        let keysToRemove = memoryCache.keys.filter { $0.hasPrefix(languagePrefix) }
        for key in keysToRemove {
            memoryCache.removeValue(forKey: key)
            currentCacheSize -= 1
        }
        
        // Remove from disk cache
        clearDiskCacheForLanguage(language)
    }
    
    /// Get cache statistics
    /// - Returns: CacheStatistics object
    public func getStatistics() -> CacheStatistics {
        let totalItems = memoryCache.count
        let expiredItems = memoryCache.values.filter { $0.isExpired }.count
        let validItems = totalItems - expiredItems
        
        let hitRate = calculateHitRate()
        
        return CacheStatistics(
            cacheSize: validItems,
            maxCacheSize: maxCacheSize,
            hitRate: hitRate,
            totalItems: totalItems,
            expiredItems: expiredItems,
            memoryUsage: calculateMemoryUsage(),
            diskUsage: calculateDiskUsage()
        )
    }
    
    // MARK: - Private Methods
    
    private func generateCacheKey(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) -> String {
        let combined = "\(sourceLanguage.code)_\(targetLanguage.code)_\(text)"
        return combined.sha256()
    }
    
    private func cacheItem(_ item: CachedItem) {
        // Remove old item if exists
        if let oldItem = memoryCache[item.key] {
            currentCacheSize -= 1
        }
        
        // Add new item
        memoryCache[item.key] = item
        currentCacheSize += 1
        
        // Cleanup if needed
        cleanupCacheIfNeeded()
        
        // Save to disk
        saveItemToDisk(item)
    }
    
    private func cleanupCacheIfNeeded() {
        guard currentCacheSize > maxCacheSize else { return }
        
        // Remove expired items first
        let expiredKeys = memoryCache.keys.filter { memoryCache[$0]?.isExpired == true }
        for key in expiredKeys {
            memoryCache.removeValue(forKey: key)
            currentCacheSize -= 1
        }
        
        // If still over limit, remove oldest items
        if currentCacheSize > maxCacheSize {
            let sortedItems = memoryCache.sorted { $0.value.timestamp < $1.value.timestamp }
            let itemsToRemove = currentCacheSize - maxCacheSize
            
            for i in 0..<itemsToRemove {
                let key = sortedItems[i].key
                memoryCache.removeValue(forKey: key)
                currentCacheSize -= 1
            }
        }
    }
    
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func saveItemToDisk(_ item: CachedItem) {
        let fileURL = cacheDirectory.appendingPathComponent("\(item.key).cache")
        
        do {
            let data = try JSONEncoder().encode(item)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save cache item to disk: \(error)")
        }
    }
    
    private func loadItemFromDisk(key: String) -> CachedItem? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).cache")
        
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        
        do {
            let item = try JSONDecoder().decode(CachedItem.self, from: data)
            return item
        } catch {
            print("Failed to load cache item from disk: \(error)")
            return nil
        }
    }
    
    private func saveModelToDisk(key: String, data: Data) {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).model")
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Failed to save model to disk: \(error)")
        }
    }
    
    private func loadModelFromDisk(key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).model")
        
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            return nil
        }
    }
    
    private func loadCacheFromDisk() {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            let cacheFiles = files.filter { $0.pathExtension == "cache" }
            
            for file in cacheFiles {
                if let data = try? Data(contentsOf: file),
                   let item = try? JSONDecoder().decode(CachedItem.self, from: data),
                   !item.isExpired {
                    memoryCache[item.key] = item
                    currentCacheSize += 1
                }
            }
        } catch {
            print("Failed to load cache from disk: \(error)")
        }
    }
    
    private func saveCacheToDisk() {
        for item in memoryCache.values {
            saveItemToDisk(item)
        }
    }
    
    private func clearDiskCache() {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("Failed to clear disk cache: \(error)")
        }
    }
    
    private func clearDiskCacheForLanguage(_ language: Language) {
        let languagePrefix = "\(language.code)_"
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            let filesToRemove = files.filter { $0.lastPathComponent.hasPrefix(languagePrefix) }
            
            for file in filesToRemove {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("Failed to clear disk cache for language: \(error)")
        }
    }
    
    private func calculateHitRate() -> Float {
        // This would require tracking actual hits and misses
        // For now, return a placeholder value
        return 0.8
    }
    
    private func calculateMemoryUsage() -> Int64 {
        // Calculate approximate memory usage
        var totalSize: Int64 = 0
        for item in memoryCache.values {
            totalSize += Int64(item.value.count)
        }
        return totalSize
    }
    
    private func calculateDiskUsage() -> Int64 {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            var totalSize: Int64 = 0
            
            for file in files {
                if let size = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(size)
                }
            }
            
            return totalSize
        } catch {
            return 0
        }
    }
}

// MARK: - Supporting Types

public struct CachedItem: Codable {
    public let key: String
    public let value: String
    public let timestamp: Date
    public let type: CacheItemType
    public let metadata: [String: String]
    
    public var isExpired: Bool {
        let expirationInterval: TimeInterval = 24 * 60 * 60 // 24 hours
        return Date().timeIntervalSince(timestamp) > expirationInterval
    }
    
    public init(
        key: String,
        value: String,
        timestamp: Date,
        type: CacheItemType,
        metadata: [String: String]
    ) {
        self.key = key
        self.value = value
        self.timestamp = timestamp
        self.type = type
        self.metadata = metadata
    }
}

public enum CacheItemType: String, Codable, CaseIterable {
    case translation = "translation"
    case languageModel = "languageModel"
    case voiceRecognition = "voiceRecognition"
    case other = "other"
}

public struct CacheStatistics {
    public let cacheSize: Int
    public let maxCacheSize: Int
    public let hitRate: Float
    public let totalItems: Int
    public let expiredItems: Int
    public let memoryUsage: Int64
    public let diskUsage: Int64
    
    public init(
        cacheSize: Int,
        maxCacheSize: Int,
        hitRate: Float,
        totalItems: Int,
        expiredItems: Int,
        memoryUsage: Int64,
        diskUsage: Int64
    ) {
        self.cacheSize = cacheSize
        self.maxCacheSize = maxCacheSize
        self.hitRate = hitRate
        self.totalItems = totalItems
        self.expiredItems = expiredItems
        self.memoryUsage = memoryUsage
        self.diskUsage = diskUsage
    }
    
    public var utilizationRate: Float {
        guard maxCacheSize > 0 else { return 0.0 }
        return Float(cacheSize) / Float(maxCacheSize)
    }
    
    public var validItems: Int {
        return totalItems - expiredItems
    }
}

// MARK: - String Extension for SHA256

extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
} 
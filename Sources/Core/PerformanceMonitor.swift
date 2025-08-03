import Foundation
import Metrics
import Logging

/// Performance monitoring and metrics collection for GlobalLingo
/// Tracks translation performance, memory usage, and system metrics
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public class PerformanceMonitor {
    
    // MARK: - Properties
    
    private let logger = Logger(label: "GlobalLingo.PerformanceMonitor")
    private var isMonitoringEnabled = false
    
    // Metrics
    private var translationTimes: [TimeInterval] = []
    private var memoryUsage: [Int64] = []
    private var cacheHitRates: [Float] = []
    private var networkRequests: [TimeInterval] = []
    private var offlineRequests: [TimeInterval] = []
    
    // Counters
    private var totalTranslations = 0
    private var successfulTranslations = 0
    private var failedTranslations = 0
    private var cacheHits = 0
    private var cacheMisses = 0
    
    // MARK: - Initialization
    
    public init() {
        setupMetrics()
    }
    
    // MARK: - Public Methods
    
    /// Enable performance monitoring
    public func enableMonitoring() {
        isMonitoringEnabled = true
        logger.info("Performance monitoring enabled")
    }
    
    /// Disable performance monitoring
    public func disableMonitoring() {
        isMonitoringEnabled = false
        logger.info("Performance monitoring disabled")
    }
    
    /// Track translation performance
    /// - Parameters:
    ///   - sourceLanguage: Source language
    ///   - targetLanguage: Target language
    ///   - textLength: Length of translated text
    public func trackTranslation(
        sourceLanguage: Language,
        targetLanguage: Language,
        textLength: Int
    ) {
        guard isMonitoringEnabled else { return }
        
        totalTranslations += 1
        
        // Track metrics
        Counter(label: "globalLingo.translations.total").increment()
        Counter(label: "globalLingo.translations.\(sourceLanguage.code)_to_\(targetLanguage.code)").increment()
        
        // Track text length
        Recorder(label: "globalLingo.text.length").record(Double(textLength))
        
        logger.debug("Translation tracked: \(sourceLanguage.code) → \(targetLanguage.code), length: \(textLength)")
    }
    
    /// Track translation time
    /// - Parameter time: Translation time in seconds
    public func trackTranslationTime(_ time: TimeInterval) {
        guard isMonitoringEnabled else { return }
        
        translationTimes.append(time)
        
        // Keep only last 1000 measurements
        if translationTimes.count > 1000 {
            translationTimes.removeFirst()
        }
        
        // Record metric
        Recorder(label: "globalLingo.translation.time").record(time)
        
        logger.debug("Translation time tracked: \(time)s")
    }
    
    /// Track memory usage
    /// - Parameter usage: Memory usage in bytes
    public func trackMemoryUsage(_ usage: Int64) {
        guard isMonitoringEnabled else { return }
        
        memoryUsage.append(usage)
        
        // Keep only last 100 measurements
        if memoryUsage.count > 100 {
            memoryUsage.removeFirst()
        }
        
        // Record metric
        Recorder(label: "globalLingo.memory.usage").record(Double(usage))
        
        logger.debug("Memory usage tracked: \(usage) bytes")
    }
    
    /// Track cache hit
    public func trackCacheHit() {
        guard isMonitoringEnabled else { return }
        
        cacheHits += 1
        Counter(label: "globalLingo.cache.hits").increment()
        
        updateCacheHitRate()
        
        logger.debug("Cache hit tracked")
    }
    
    /// Track cache miss
    public func trackCacheMiss() {
        guard isMonitoringEnabled else { return }
        
        cacheMisses += 1
        Counter(label: "globalLingo.cache.misses").increment()
        
        updateCacheHitRate()
        
        logger.debug("Cache miss tracked")
    }
    
    /// Track successful translation
    public func trackSuccessfulTranslation() {
        guard isMonitoringEnabled else { return }
        
        successfulTranslations += 1
        Counter(label: "globalLingo.translations.successful").increment()
        
        logger.debug("Successful translation tracked")
    }
    
    /// Track failed translation
    public func trackFailedTranslation() {
        guard isMonitoringEnabled else { return }
        
        failedTranslations += 1
        Counter(label: "globalLingo.translations.failed").increment()
        
        logger.debug("Failed translation tracked")
    }
    
    /// Track network request time
    /// - Parameter time: Request time in seconds
    public func trackNetworkRequest(_ time: TimeInterval) {
        guard isMonitoringEnabled else { return }
        
        networkRequests.append(time)
        
        // Keep only last 1000 measurements
        if networkRequests.count > 1000 {
            networkRequests.removeFirst()
        }
        
        // Record metric
        Recorder(label: "globalLingo.network.request.time").record(time)
        
        logger.debug("Network request time tracked: \(time)s")
    }
    
    /// Track offline request time
    /// - Parameter time: Request time in seconds
    public func trackOfflineRequest(_ time: TimeInterval) {
        guard isMonitoringEnabled else { return }
        
        offlineRequests.append(time)
        
        // Keep only last 1000 measurements
        if offlineRequests.count > 1000 {
            offlineRequests.removeFirst()
        }
        
        // Record metric
        Recorder(label: "globalLingo.offline.request.time").record(time)
        
        logger.debug("Offline request time tracked: \(time)s")
    }
    
    /// Get current performance metrics
    /// - Returns: PerformanceMetrics object with current metrics
    public func getMetrics() -> PerformanceMetrics {
        return PerformanceMetrics(
            averageResponseTime: calculateAverageResponseTime(),
            memoryUsage: getCurrentMemoryUsage(),
            cpuUsage: getCurrentCPUUsage(),
            gpuUsage: getCurrentGPUUsage(),
            cacheHitRate: calculateCacheHitRate(),
            networkRequests: networkRequests.count,
            offlineRequests: offlineRequests.count,
            totalTranslations: totalTranslations,
            successfulTranslations: successfulTranslations,
            failedTranslations: failedTranslations,
            cacheHits: cacheHits,
            cacheMisses: cacheMisses
        )
    }
    
    /// Generate performance report
    /// - Returns: Detailed performance report
    public func generateReport() -> PerformanceReport {
        let metrics = getMetrics()
        
        return PerformanceReport(
            timestamp: Date(),
            metrics: metrics,
            recommendations: generateRecommendations(metrics: metrics),
            alerts: generateAlerts(metrics: metrics)
        )
    }
    
    /// Clear all metrics
    public func clearMetrics() {
        translationTimes.removeAll()
        memoryUsage.removeAll()
        cacheHitRates.removeAll()
        networkRequests.removeAll()
        offlineRequests.removeAll()
        
        totalTranslations = 0
        successfulTranslations = 0
        failedTranslations = 0
        cacheHits = 0
        cacheMisses = 0
        
        logger.info("All metrics cleared")
    }
    
    // MARK: - Private Methods
    
    private func setupMetrics() {
        // Initialize metrics system
        MetricsSystem.bootstrap()
    }
    
    private func calculateAverageResponseTime() -> TimeInterval {
        guard !translationTimes.isEmpty else { return 0.0 }
        return translationTimes.reduce(0, +) / Double(translationTimes.count)
    }
    
    private func getCurrentMemoryUsage() -> Int64 {
        guard !memoryUsage.isEmpty else { return 0 }
        return memoryUsage.last ?? 0
    }
    
    private func getCurrentCPUUsage() -> Float {
        // This would require system-specific implementation
        // For now, return a placeholder value
        return 0.0
    }
    
    private func getCurrentGPUUsage() -> Float? {
        // This would require system-specific implementation
        // For now, return nil
        return nil
    }
    
    private func calculateCacheHitRate() -> Float {
        let totalRequests = cacheHits + cacheMisses
        guard totalRequests > 0 else { return 0.0 }
        return Float(cacheHits) / Float(totalRequests)
    }
    
    private func updateCacheHitRate() {
        let hitRate = calculateCacheHitRate()
        cacheHitRates.append(hitRate)
        
        // Keep only last 100 measurements
        if cacheHitRates.count > 100 {
            cacheHitRates.removeFirst()
        }
        
        // Record metric
        Recorder(label: "globalLingo.cache.hit.rate").record(Double(hitRate))
    }
    
    private func generateRecommendations(metrics: PerformanceMetrics) -> [String] {
        var recommendations: [String] = []
        
        // Check response time
        if metrics.averageResponseTime > 1.0 {
            recommendations.append("Consider optimizing translation algorithms for faster response times")
        }
        
        // Check memory usage
        if metrics.memoryUsage > 200 * 1024 * 1024 { // 200MB
            recommendations.append("Memory usage is high. Consider implementing memory optimization strategies")
        }
        
        // Check cache hit rate
        if metrics.cacheHitRate < 0.5 {
            recommendations.append("Cache hit rate is low. Consider increasing cache size or improving cache strategy")
        }
        
        // Check success rate
        let successRate = Double(metrics.successfulTranslations) / Double(metrics.totalTranslations)
        if successRate < 0.95 {
            recommendations.append("Translation success rate is below 95%. Review error handling and network connectivity")
        }
        
        return recommendations
    }
    
    private func generateAlerts(metrics: PerformanceMetrics) -> [PerformanceAlert] {
        var alerts: [PerformanceAlert] = []
        
        // Check for critical issues
        if metrics.averageResponseTime > 5.0 {
            alerts.append(PerformanceAlert(
                level: .critical,
                message: "Translation response time is critically high",
                metric: "averageResponseTime",
                value: metrics.averageResponseTime
            ))
        }
        
        if metrics.memoryUsage > 500 * 1024 * 1024 { // 500MB
            alerts.append(PerformanceAlert(
                level: .warning,
                message: "Memory usage is very high",
                metric: "memoryUsage",
                value: Double(metrics.memoryUsage)
            ))
        }
        
        if metrics.cacheHitRate < 0.3 {
            alerts.append(PerformanceAlert(
                level: .warning,
                message: "Cache hit rate is very low",
                metric: "cacheHitRate",
                value: Double(metrics.cacheHitRate)
            ))
        }
        
        return alerts
    }
}

// MARK: - Supporting Types

public struct PerformanceMetrics {
    public let averageResponseTime: TimeInterval
    public let memoryUsage: Int64
    public let cpuUsage: Float
    public let gpuUsage: Float?
    public let cacheHitRate: Float
    public let networkRequests: Int
    public let offlineRequests: Int
    public let totalTranslations: Int
    public let successfulTranslations: Int
    public let failedTranslations: Int
    public let cacheHits: Int
    public let cacheMisses: Int
    
    public init(
        averageResponseTime: TimeInterval,
        memoryUsage: Int64,
        cpuUsage: Float,
        gpuUsage: Float?,
        cacheHitRate: Float,
        networkRequests: Int,
        offlineRequests: Int,
        totalTranslations: Int,
        successfulTranslations: Int,
        failedTranslations: Int,
        cacheHits: Int,
        cacheMisses: Int
    ) {
        self.averageResponseTime = averageResponseTime
        self.memoryUsage = memoryUsage
        self.cpuUsage = cpuUsage
        self.gpuUsage = gpuUsage
        self.cacheHitRate = cacheHitRate
        self.networkRequests = networkRequests
        self.offlineRequests = offlineRequests
        self.totalTranslations = totalTranslations
        self.successfulTranslations = successfulTranslations
        self.failedTranslations = failedTranslations
        self.cacheHits = cacheHits
        self.cacheMisses = cacheMisses
    }
    
    public var successRate: Double {
        guard totalTranslations > 0 else { return 0.0 }
        return Double(successfulTranslations) / Double(totalTranslations)
    }
    
    public var failureRate: Double {
        guard totalTranslations > 0 else { return 0.0 }
        return Double(failedTranslations) / Double(totalTranslations)
    }
}

public struct PerformanceReport {
    public let timestamp: Date
    public let metrics: PerformanceMetrics
    public let recommendations: [String]
    public let alerts: [PerformanceAlert]
    
    public init(
        timestamp: Date,
        metrics: PerformanceMetrics,
        recommendations: [String],
        alerts: [PerformanceAlert]
    ) {
        self.timestamp = timestamp
        self.metrics = metrics
        self.recommendations = recommendations
        self.alerts = alerts
    }
}

public struct PerformanceAlert {
    public let level: AlertLevel
    public let message: String
    public let metric: String
    public let value: Double
    
    public init(
        level: AlertLevel,
        message: String,
        metric: String,
        value: Double
    ) {
        self.level = level
        self.message = message
        self.metric = metric
        self.value = value
    }
}

public enum AlertLevel: String, CaseIterable {
    case info = "Info"
    case warning = "Warning"
    case critical = "Critical"
    
    public var color: String {
        switch self {
        case .info: return "blue"
        case .warning: return "yellow"
        case .critical: return "red"
        }
    }
} 
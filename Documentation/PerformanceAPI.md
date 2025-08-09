# Performance API

<!-- TOC START -->
## Table of Contents
- [Performance API](#performance-api)
- [Overview](#overview)
- [Core Classes](#core-classes)
  - [PerformanceManager](#performancemanager)
  - [PerformanceConfiguration](#performanceconfiguration)
  - [PerformanceMetrics](#performancemetrics)
  - [MemoryMetrics](#memorymetrics)
  - [CPUMetrics](#cpumetrics)
  - [NetworkMetrics](#networkmetrics)
  - [BatteryMetrics](#batterymetrics)
  - [FrameRateMetrics](#frameratemetrics)
  - [PerformanceThreshold](#performancethreshold)
  - [PerformanceMetric](#performancemetric)
  - [ThresholdAction](#thresholdaction)
  - [MemoryPressure](#memorypressure)
  - [NetworkConnectionType](#networkconnectiontype)
  - [PerformanceError](#performanceerror)
- [Usage Examples](#usage-examples)
  - [Basic Performance Monitoring](#basic-performance-monitoring)
  - [Performance Optimization](#performance-optimization)
  - [Performance Thresholds](#performance-thresholds)
  - [Performance Reports](#performance-reports)
- [Advanced Features](#advanced-features)
  - [Custom Metrics](#custom-metrics)
  - [Performance Alerts](#performance-alerts)
  - [Performance Logging](#performance-logging)
  - [Performance Analytics](#performance-analytics)
- [Integration Examples](#integration-examples)
  - [SwiftUI Integration](#swiftui-integration)
  - [UIKit Integration](#uikit-integration)
- [Testing](#testing)
  - [Unit Tests](#unit-tests)
- [Best Practices](#best-practices)
- [Migration Guide](#migration-guide)
  - [From Version 1.0 to 2.0](#from-version-10-to-20)
  - [Breaking Changes](#breaking-changes)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Solutions](#solutions)
- [Support](#support)
<!-- TOC END -->


## Overview

The Performance API provides comprehensive performance monitoring, optimization, and analytics capabilities for iOS applications, including memory management, CPU profiling, network optimization, and performance metrics.

## Core Classes

### PerformanceManager

The main performance manager that orchestrates all performance-related operations.

```swift
public class PerformanceManager {
    public init()
    public func configure(_ configuration: PerformanceConfiguration)
    public func startMonitoring(completion: @escaping (Result<Void, PerformanceError>) -> Void)
    public func stopMonitoring(completion: @escaping (Result<Void, PerformanceError>) -> Void)
    public func getMetrics(completion: @escaping (Result<PerformanceMetrics, PerformanceError>) -> Void)
    public func optimizeMemory(completion: @escaping (Result<MemoryOptimization, PerformanceError>) -> Void)
    public func optimizeCPU(completion: @escaping (Result<CPUOptimization, PerformanceError>) -> Void)
    public func optimizeNetwork(completion: @escaping (Result<NetworkOptimization, PerformanceError>) -> Void)
    public func generateReport(completion: @escaping (Result<PerformanceReport, PerformanceError>) -> Void)
    public func setThreshold(_ threshold: PerformanceThreshold, forMetric: PerformanceMetric)
    public func getThreshold(forMetric: PerformanceMetric) -> PerformanceThreshold?
}
```

### PerformanceConfiguration

Configuration options for the performance manager.

```swift
public struct PerformanceConfiguration {
    public var enableMemoryMonitoring: Bool
    public var enableCPUMonitoring: Bool
    public var enableNetworkMonitoring: Bool
    public var enableBatteryMonitoring: Bool
    public var enableFrameRateMonitoring: Bool
    public var enableCrashMonitoring: Bool
    public var enableCustomMetrics: Bool
    public var samplingInterval: TimeInterval
    public var reportingInterval: TimeInterval
    public var alertThresholds: [PerformanceMetric: PerformanceThreshold]
    public var enableRealTimeAlerts: Bool
    public var enablePerformanceLogging: Bool
}
```

### PerformanceMetrics

Represents comprehensive performance metrics.

```swift
public struct PerformanceMetrics {
    public let memory: MemoryMetrics
    public let cpu: CPUMetrics
    public let network: NetworkMetrics
    public let battery: BatteryMetrics
    public let frameRate: FrameRateMetrics
    public let custom: [String: Double]
    public let timestamp: Date
    public let sessionId: String
}
```

### MemoryMetrics

Represents memory-related performance metrics.

```swift
public struct MemoryMetrics {
    public let totalMemory: UInt64
    public let usedMemory: UInt64
    public let availableMemory: UInt64
    public let memoryPressure: MemoryPressure
    public let memoryWarnings: Int
    public let peakMemoryUsage: UInt64
    public let averageMemoryUsage: UInt64
    public let memoryLeaks: [MemoryLeak]
}
```

### CPUMetrics

Represents CPU-related performance metrics.

```swift
public struct CPUMetrics {
    public let cpuUsage: Double
    public let cpuTemperature: Double?
    public let threadCount: Int
    public let activeThreads: Int
    public let cpuTime: TimeInterval
    public let userTime: TimeInterval
    public let systemTime: TimeInterval
    public let idleTime: TimeInterval
}
```

### NetworkMetrics

Represents network-related performance metrics.

```swift
public struct NetworkMetrics {
    public let bytesSent: UInt64
    public let bytesReceived: UInt64
    public let requestCount: Int
    public let responseTime: TimeInterval
    public let errorRate: Double
    public let bandwidth: Double
    public let connectionType: NetworkConnectionType
    public let latency: TimeInterval
}
```

### BatteryMetrics

Represents battery-related performance metrics.

```swift
public struct BatteryMetrics {
    public let batteryLevel: Double
    public let batteryState: UIDevice.BatteryState
    public let isCharging: Bool
    public let powerConsumption: Double
    public let estimatedTimeRemaining: TimeInterval?
    public let temperature: Double?
}
```

### FrameRateMetrics

Represents frame rate performance metrics.

```swift
public struct FrameRateMetrics {
    public let currentFPS: Double
    public let averageFPS: Double
    public let minFPS: Double
    public let maxFPS: Double
    public let frameDrops: Int
    public let frameTime: TimeInterval
    public let renderTime: TimeInterval
    public let vsyncMisses: Int
}
```

### PerformanceThreshold

Represents performance thresholds for alerts.

```swift
public struct PerformanceThreshold {
    public let metric: PerformanceMetric
    public let warningValue: Double
    public let criticalValue: Double
    public let action: ThresholdAction
    public let isEnabled: Bool
}
```

### PerformanceMetric

Enumeration of performance metric types.

```swift
public enum PerformanceMetric {
    case memoryUsage
    case cpuUsage
    case networkLatency
    case batteryLevel
    case frameRate
    case responseTime
    case errorRate
    case custom(String)
}
```

### ThresholdAction

Enumeration of threshold action types.

```swift
public enum ThresholdAction {
    case log
    case alert
    case optimize
    case restart
    case custom(String)
}
```

### MemoryPressure

Enumeration of memory pressure levels.

```swift
public enum MemoryPressure {
    case normal
    case warning
    case critical
    case emergency
}
```

### NetworkConnectionType

Enumeration of network connection types.

```swift
public enum NetworkConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
}
```

### PerformanceError

Enumeration of performance error types.

```swift
public enum PerformanceError: Error {
    case configurationError(String)
    case monitoringFailed(String)
    case optimizationFailed(String)
    case reportGenerationFailed(String)
    case thresholdExceeded(PerformanceMetric, Double)
    case memoryError(String)
    case cpuError(String)
    case networkError(String)
}
```

## Usage Examples

### Basic Performance Monitoring

```swift
let performanceManager = PerformanceManager()

let config = PerformanceConfiguration()
config.enableMemoryMonitoring = true
config.enableCPUMonitoring = true
config.enableNetworkMonitoring = true
config.samplingInterval = 1.0
config.reportingInterval = 60.0
config.enableRealTimeAlerts = true

performanceManager.configure(config)

// Start monitoring
performanceManager.startMonitoring { result in
    switch result {
    case .success:
        print("Performance monitoring started")
    case .failure(let error):
        print("Failed to start monitoring: \(error)")
    }
}

// Get current metrics
performanceManager.getMetrics { result in
    switch result {
    case .success(let metrics):
        print("Memory usage: \(metrics.memory.usedMemory) bytes")
        print("CPU usage: \(metrics.cpu.cpuUsage)%")
        print("Network latency: \(metrics.network.latency) seconds")
        print("Battery level: \(metrics.battery.batteryLevel)%")
        print("Frame rate: \(metrics.frameRate.currentFPS) FPS")
    case .failure(let error):
        print("Failed to get metrics: \(error)")
    }
}
```

### Performance Optimization

```swift
// Optimize memory
performanceManager.optimizeMemory { result in
    switch result {
    case .success(let optimization):
        print("Memory optimization completed")
        print("Memory freed: \(optimization.memoryFreed) bytes")
        print("Optimization time: \(optimization.optimizationTime) seconds")
        print("Recommendations: \(optimization.recommendations)")
    case .failure(let error):
        print("Memory optimization failed: \(error)")
    }
}

// Optimize CPU
performanceManager.optimizeCPU { result in
    switch result {
    case .success(let optimization):
        print("CPU optimization completed")
        print("CPU usage reduction: \(optimization.cpuUsageReduction)%")
        print("Thread optimization: \(optimization.threadOptimization)")
        print("Performance improvement: \(optimization.performanceImprovement)")
    case .failure(let error):
        print("CPU optimization failed: \(error)")
    }
}

// Optimize network
performanceManager.optimizeNetwork { result in
    switch result {
    case .success(let optimization):
        print("Network optimization completed")
        print("Latency reduction: \(optimization.latencyReduction) seconds")
        print("Bandwidth improvement: \(optimization.bandwidthImprovement)%")
        print("Connection optimization: \(optimization.connectionOptimization)")
    case .failure(let error):
        print("Network optimization failed: \(error)")
    }
}
```

### Performance Thresholds

```swift
// Set memory usage threshold
let memoryThreshold = PerformanceThreshold(
    metric: .memoryUsage,
    warningValue: 0.7, // 70%
    criticalValue: 0.9, // 90%
    action: .alert,
    isEnabled: true
)

performanceManager.setThreshold(memoryThreshold, forMetric: .memoryUsage)

// Set CPU usage threshold
let cpuThreshold = PerformanceThreshold(
    metric: .cpuUsage,
    warningValue: 0.8, // 80%
    criticalValue: 0.95, // 95%
    action: .optimize,
    isEnabled: true
)

performanceManager.setThreshold(cpuThreshold, forMetric: .cpuUsage)

// Set frame rate threshold
let frameRateThreshold = PerformanceThreshold(
    metric: .frameRate,
    warningValue: 30.0, // 30 FPS
    criticalValue: 20.0, // 20 FPS
    action: .log,
    isEnabled: true
)

performanceManager.setThreshold(frameRateThreshold, forMetric: .frameRate)
```

### Performance Reports

```swift
// Generate performance report
performanceManager.generateReport { result in
    switch result {
    case .success(let report):
        print("Performance report generated")
        print("Report ID: \(report.reportId)")
        print("Session duration: \(report.sessionDuration) seconds")
        print("Average memory usage: \(report.averageMemoryUsage) bytes")
        print("Average CPU usage: \(report.averageCPUUsage)%")
        print("Total network requests: \(report.totalNetworkRequests)")
        print("Performance score: \(report.performanceScore)")
        print("Recommendations: \(report.recommendations)")
    case .failure(let error):
        print("Report generation failed: \(error)")
    }
}
```

## Advanced Features

### Custom Metrics

```swift
public protocol CustomMetricsProvider {
    func getCustomMetrics() -> [String: Double]
    func setCustomMetric(_ value: Double, forKey: String)
    func removeCustomMetric(forKey: String)
    func clearCustomMetrics()
}
```

### Performance Alerts

```swift
public protocol PerformanceAlertDelegate: AnyObject {
    func performanceAlert(_ alert: PerformanceAlert)
    func thresholdExceeded(_ threshold: PerformanceThreshold, currentValue: Double)
    func performanceWarning(_ warning: PerformanceWarning)
    func performanceCritical(_ critical: PerformanceCritical)
}
```

### Performance Logging

```swift
public protocol PerformanceLogger {
    func logMetric(_ metric: PerformanceMetric, value: Double)
    func logEvent(_ event: PerformanceEvent)
    func logError(_ error: PerformanceError)
    func exportLogs() -> Data
    func clearLogs()
}
```

### Performance Analytics

```swift
public protocol PerformanceAnalytics {
    func analyzeTrends(forMetric: PerformanceMetric, duration: TimeInterval) -> TrendAnalysis
    func predictPerformance(forMetric: PerformanceMetric) -> PerformancePrediction
    func identifyBottlenecks() -> [PerformanceBottleneck]
    func generateInsights() -> [PerformanceInsight]
}
```

## Integration Examples

### SwiftUI Integration

```swift
struct PerformanceView: View {
    @StateObject private var performanceManager = PerformanceManager()
    @State private var metrics: PerformanceMetrics?
    @State private var isMonitoring = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let metrics = metrics {
                MetricsDisplayView(metrics: metrics)
            }
            
            Button(isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
                toggleMonitoring()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Optimize Performance") {
                optimizePerformance()
            }
            .buttonStyle(.bordered)
            
            Button("Generate Report") {
                generateReport()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            setupPerformanceManager()
        }
    }
    
    private func setupPerformanceManager() {
        let config = PerformanceConfiguration()
        config.enableMemoryMonitoring = true
        config.enableCPUMonitoring = true
        config.enableNetworkMonitoring = true
        config.samplingInterval = 2.0
        performanceManager.configure(config)
    }
    
    private func toggleMonitoring() {
        if isMonitoring {
            performanceManager.stopMonitoring { _ in
                DispatchQueue.main.async {
                    isMonitoring = false
                }
            }
        } else {
            performanceManager.startMonitoring { _ in
                DispatchQueue.main.async {
                    isMonitoring = true
                    updateMetrics()
                }
            }
        }
    }
    
    private func updateMetrics() {
        performanceManager.getMetrics { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newMetrics):
                    metrics = newMetrics
                case .failure:
                    break
                }
            }
        }
    }
    
    private func optimizePerformance() {
        performanceManager.optimizeMemory { _ in }
        performanceManager.optimizeCPU { _ in }
        performanceManager.optimizeNetwork { _ in }
    }
    
    private func generateReport() {
        performanceManager.generateReport { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let report):
                    print("Report generated: \(report.reportId)")
                case .failure(let error):
                    print("Report failed: \(error)")
                }
            }
        }
    }
}

struct MetricsDisplayView: View {
    let metrics: PerformanceMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Memory: \(ByteCountFormatter.string(fromByteCount: Int64(metrics.memory.usedMemory), countStyle: .memory))")
            Text("CPU: \(String(format: "%.1f", metrics.cpu.cpuUsage))%")
            Text("Battery: \(String(format: "%.0f", metrics.battery.batteryLevel * 100))%")
            Text("FPS: \(String(format: "%.1f", metrics.frameRate.currentFPS))")
        }
        .font(.caption)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
```

### UIKit Integration

```swift
class PerformanceViewController: UIViewController {
    private let performanceManager = PerformanceManager()
    private let metricsLabel = UILabel()
    private let startButton = UIButton()
    private let optimizeButton = UIButton()
    private var isMonitoring = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPerformanceManager()
    }
    
    private func setupPerformanceManager() {
        let config = PerformanceConfiguration()
        config.enableMemoryMonitoring = true
        config.enableCPUMonitoring = true
        config.enableNetworkMonitoring = true
        config.samplingInterval = 2.0
        performanceManager.configure(config)
    }
    
    @objc private func startButtonTapped() {
        if isMonitoring {
            performanceManager.stopMonitoring { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isMonitoring = false
                    self?.startButton.setTitle("Start Monitoring", for: .normal)
                }
            }
        } else {
            performanceManager.startMonitoring { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isMonitoring = true
                    self?.startButton.setTitle("Stop Monitoring", for: .normal)
                    self?.updateMetrics()
                }
            }
        }
    }
    
    @objc private func optimizeButtonTapped() {
        performanceManager.optimizeMemory { _ in }
        performanceManager.optimizeCPU { _ in }
        performanceManager.optimizeNetwork { _ in }
    }
    
    private func updateMetrics() {
        performanceManager.getMetrics { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let metrics):
                    self?.displayMetrics(metrics)
                case .failure:
                    break
                }
            }
        }
    }
    
    private func displayMetrics(_ metrics: PerformanceMetrics) {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        
        let memoryText = formatter.string(fromByteCount: Int64(metrics.memory.usedMemory))
        let cpuText = String(format: "%.1f%%", metrics.cpu.cpuUsage)
        let batteryText = String(format: "%.0f%%", metrics.battery.batteryLevel * 100)
        let fpsText = String(format: "%.1f FPS", metrics.frameRate.currentFPS)
        
        metricsLabel.text = """
        Memory: \(memoryText)
        CPU: \(cpuText)
        Battery: \(batteryText)
        FPS: \(fpsText)
        """
    }
}
```

## Testing

### Unit Tests

```swift
class PerformanceManagerTests: XCTestCase {
    var performanceManager: PerformanceManager!
    
    override func setUp() {
        super.setUp()
        performanceManager = PerformanceManager()
    }
    
    override func tearDown() {
        performanceManager = nil
        super.tearDown()
    }
    
    func testConfiguration() {
        let config = PerformanceConfiguration()
        config.enableMemoryMonitoring = true
        config.enableCPUMonitoring = true
        config.samplingInterval = 1.0
        
        performanceManager.configure(config)
        
        // Verify configuration was applied
        // Add assertions based on your implementation
    }
    
    func testStartMonitoring() {
        let expectation = XCTestExpectation(description: "Monitoring started")
        
        performanceManager.startMonitoring { result in
            switch result {
            case .success:
                // Monitoring started successfully
                break
            case .failure(let error):
                XCTFail("Failed to start monitoring: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetMetrics() {
        let expectation = XCTestExpectation(description: "Metrics retrieved")
        
        performanceManager.getMetrics { result in
            switch result {
            case .success(let metrics):
                XCTAssertNotNil(metrics)
                XCTAssertNotNil(metrics.memory)
                XCTAssertNotNil(metrics.cpu)
                XCTAssertNotNil(metrics.battery)
            case .failure(let error):
                XCTFail("Failed to get metrics: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
```

## Best Practices

1. **Always configure the performance manager before use**
2. **Set appropriate thresholds for your application**
3. **Monitor performance continuously in production**
4. **Implement proper error handling for all performance operations**
5. **Use performance reports to identify bottlenecks**
6. **Optimize performance proactively**
7. **Monitor memory usage and prevent leaks**
8. **Track network performance and optimize requests**
9. **Monitor battery usage and optimize power consumption**
10. **Use custom metrics for application-specific performance tracking**

## Migration Guide

### From Version 1.0 to 2.0

1. **Update configuration initialization**
2. **Replace deprecated methods**
3. **Update error handling**
4. **Migrate to new API structure**

### Breaking Changes

- `PerformanceManager.init()` now requires configuration
- Error types have been reorganized
- Some method signatures have changed

## Troubleshooting

### Common Issues

1. **High memory usage**
2. **High CPU usage**
3. **Network performance issues**
4. **Battery drain**
5. **Frame rate drops**

### Solutions

1. **Implement memory optimization**
2. **Optimize CPU-intensive operations**
3. **Optimize network requests**
4. **Reduce background processing**
5. **Optimize rendering pipeline**

## Support

For additional support and documentation:

- [Getting Started Guide](GettingStarted.md)
- [Performance Guide](PerformanceGuide.md)
- [API Reference](API.md)
- [Examples](../Examples/PerformanceExamples/)
- [GitHub Issues](https://github.com/muhittincamdali/GlobalLingo/issues)

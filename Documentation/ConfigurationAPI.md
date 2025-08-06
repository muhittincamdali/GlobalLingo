# Configuration API

## Overview

The Configuration API provides comprehensive configuration management capabilities for iOS applications, including dynamic configuration, feature flags, environment management, and configuration validation.

## Core Classes

### ConfigurationManager

The main configuration manager that orchestrates all configuration-related operations.

```swift
public class ConfigurationManager {
    public init()
    public func configure(_ configuration: ConfigurationSettings)
    public func loadConfiguration(from source: ConfigurationSource, completion: @escaping (Result<Configuration, ConfigurationError>) -> Void)
    public func saveConfiguration(_ configuration: Configuration, to source: ConfigurationSource, completion: @escaping (Result<Void, ConfigurationError>) -> Void)
    public func getValue<T>(for key: String, defaultValue: T) -> T
    public func setValue<T>(_ value: T, for key: String, completion: @escaping (Result<Void, ConfigurationError>) -> Void)
    public func validateConfiguration(_ configuration: Configuration) -> ConfigurationValidationResult
    public func resetConfiguration(completion: @escaping (Result<Void, ConfigurationError>) -> Void)
    public func exportConfiguration() -> Data?
    public func importConfiguration(from data: Data, completion: @escaping (Result<Void, ConfigurationError>) -> Void)
}
```

### ConfigurationSettings

Configuration options for the configuration manager.

```swift
public struct ConfigurationSettings {
    public var enableDynamicConfiguration: Bool
    public var enableFeatureFlags: Bool
    public var enableEnvironmentManagement: Bool
    public var enableConfigurationValidation: Bool
    public var enableConfigurationCaching: Bool
    public var enableRemoteConfiguration: Bool
    public var enableConfigurationEncryption: Bool
    public var enableConfigurationBackup: Bool
    public var defaultConfigurationSource: ConfigurationSource
    public var backupConfigurationSource: ConfigurationSource?
    public var validationRules: [ConfigurationValidationRule]
    public var encryptionKey: String?
}
```

### Configuration

Represents a configuration object.

```swift
public struct Configuration {
    public let id: String
    public let version: String
    public let environment: String
    public let timestamp: Date
    public let values: [String: Any]
    public let metadata: [String: Any]
    public let validationStatus: ConfigurationValidationStatus
    public let source: ConfigurationSource
}
```

### ConfigurationSource

Enumeration of configuration sources.

```swift
public enum ConfigurationSource {
    case local
    case remote
    case userDefaults
    case keychain
    case file(path: String)
    case network(url: URL)
    case custom(identifier: String)
}
```

### ConfigurationValidationStatus

Enumeration of configuration validation statuses.

```swift
public enum ConfigurationValidationStatus {
    case valid
    case invalid([ConfigurationValidationError])
    case pending
    case unknown
}
```

### ConfigurationValidationResult

Represents configuration validation results.

```swift
public struct ConfigurationValidationResult {
    public let isValid: Bool
    public let errors: [ConfigurationValidationError]
    public let warnings: [ConfigurationValidationWarning]
    public let timestamp: Date
    public let validationDuration: TimeInterval
}
```

### ConfigurationValidationError

Represents configuration validation errors.

```swift
public struct ConfigurationValidationError {
    public let key: String
    public let errorType: ConfigurationErrorType
    public let message: String
    public let severity: ConfigurationErrorSeverity
    public let suggestedValue: Any?
}
```

### ConfigurationErrorType

Enumeration of configuration error types.

```swift
public enum ConfigurationErrorType {
    case missingRequiredKey
    case invalidValueType
    case valueOutOfRange
    case invalidFormat
    case dependencyMissing
    case circularDependency
    case encryptionError
    case decryptionError
}
```

### ConfigurationErrorSeverity

Enumeration of configuration error severities.

```swift
public enum ConfigurationErrorSeverity {
    case low
    case medium
    case high
    case critical
}
```

### ConfigurationError

Enumeration of configuration error types.

```swift
public enum ConfigurationError: Error {
    case configurationNotFound(String)
    case invalidConfiguration(String)
    case validationFailed([ConfigurationValidationError])
    case encryptionFailed(String)
    case decryptionFailed(String)
    case sourceUnavailable(ConfigurationSource)
    case networkError(Error)
    case fileError(Error)
    case keychainError(Error)
}
```

## Usage Examples

### Basic Configuration

```swift
let configurationManager = ConfigurationManager()

let settings = ConfigurationSettings()
settings.enableDynamicConfiguration = true
settings.enableFeatureFlags = true
settings.enableConfigurationValidation = true
settings.defaultConfigurationSource = .local

configurationManager.configure(settings)

// Load configuration
configurationManager.loadConfiguration(from: .local) { result in
    switch result {
    case .success(let configuration):
        print("✅ Configuration loaded")
        print("Version: \(configuration.version)")
        print("Environment: \(configuration.environment)")
        print("Values: \(configuration.values)")
    case .failure(let error):
        print("❌ Configuration loading failed: \(error)")
    }
}
```

### Feature Flags

```swift
// Get feature flag value
let isFeatureEnabled = configurationManager.getValue(for: "feature.new_ui", defaultValue: false)
let maxRetryCount = configurationManager.getValue(for: "network.max_retries", defaultValue: 3)
let apiTimeout = configurationManager.getValue(for: "network.timeout", defaultValue: 30.0)

// Set feature flag
configurationManager.setValue(true, for: "feature.new_ui") { result in
    switch result {
    case .success:
        print("✅ Feature flag updated")
    case .failure(let error):
        print("❌ Feature flag update failed: \(error)")
    }
}
```

### Environment Management

```swift
// Load environment-specific configuration
let environments = ["development", "staging", "production"]

for environment in environments {
    configurationManager.loadConfiguration(from: .file(path: "config_\(environment).json")) { result in
        switch result {
        case .success(let configuration):
            print("✅ \(environment) configuration loaded")
        case .failure(let error):
            print("❌ \(environment) configuration failed: \(error)")
        }
    }
}
```

### Configuration Validation

```swift
// Validate configuration
let validationResult = configurationManager.validateConfiguration(configuration)

if validationResult.isValid {
    print("✅ Configuration is valid")
} else {
    print("❌ Configuration validation failed:")
    for error in validationResult.errors {
        print("- \(error.key): \(error.message)")
    }
}
```

## Advanced Features

### Remote Configuration

```swift
// Load configuration from remote source
let remoteURL = URL(string: "https://api.example.com/config")!
configurationManager.loadConfiguration(from: .network(url: remoteURL)) { result in
    switch result {
    case .success(let configuration):
        print("✅ Remote configuration loaded")
        // Apply configuration changes
        applyConfigurationChanges(configuration)
    case .failure(let error):
        print("❌ Remote configuration failed: \(error)")
        // Fallback to local configuration
        loadLocalConfiguration()
    }
}
```

### Configuration Encryption

```swift
// Encrypted configuration
let encryptedSettings = ConfigurationSettings()
encryptedSettings.enableConfigurationEncryption = true
encryptedSettings.encryptionKey = "your-secret-key"

configurationManager.configure(encryptedSettings)

// Save encrypted configuration
configurationManager.saveConfiguration(configuration, to: .keychain) { result in
    switch result {
    case .success:
        print("✅ Encrypted configuration saved")
    case .failure(let error):
        print("❌ Configuration save failed: \(error)")
    }
}
```

### Configuration Backup

```swift
// Backup configuration
configurationManager.exportConfiguration() { result in
    switch result {
    case .success(let data):
        // Save backup to file
        let backupURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("config_backup.json")
        try? data.write(to: backupURL)
        print("✅ Configuration backed up")
    case .failure(let error):
        print("❌ Configuration backup failed: \(error)")
    }
}

// Restore configuration
let backupData = // Load backup data
configurationManager.importConfiguration(from: backupData) { result in
    switch result {
    case .success:
        print("✅ Configuration restored")
    case .failure(let error):
        print("❌ Configuration restore failed: \(error)")
    }
}
```

## Integration Examples

### SwiftUI Integration

```swift
struct ConfigurationView: View {
    @StateObject private var configurationManager = ConfigurationManager()
    @State private var configuration: Configuration?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let configuration = configuration {
                ConfigurationDisplayView(configuration: configuration)
            }
            
            Button("Load Configuration") {
                loadConfiguration()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            
            Button("Reset Configuration") {
                resetConfiguration()
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
            
            if isLoading {
                ProgressView("Loading...")
            }
        }
        .padding()
        .onAppear {
            setupConfigurationManager()
        }
    }
    
    private func setupConfigurationManager() {
        let settings = ConfigurationSettings()
        settings.enableDynamicConfiguration = true
        settings.enableFeatureFlags = true
        settings.defaultConfigurationSource = .local
        configurationManager.configure(settings)
    }
    
    private func loadConfiguration() {
        isLoading = true
        
        configurationManager.loadConfiguration(from: .local) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let config):
                    configuration = config
                case .failure(let error):
                    print("Configuration loading failed: \(error)")
                }
            }
        }
    }
    
    private func resetConfiguration() {
        isLoading = true
        
        configurationManager.resetConfiguration { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    configuration = nil
                    print("Configuration reset")
                case .failure(let error):
                    print("Configuration reset failed: \(error)")
                }
            }
        }
    }
}

struct ConfigurationDisplayView: View {
    let configuration: Configuration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Configuration ID: \(configuration.id)")
                .font(.headline)
            Text("Version: \(configuration.version)")
            Text("Environment: \(configuration.environment)")
            Text("Status: \(configuration.validationStatus)")
            
            if !configuration.values.isEmpty {
                Text("Values:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(Array(configuration.values.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                            .font(.caption)
                        Spacer()
                        Text("\(String(describing: configuration.values[key]!))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
```

### UIKit Integration

```swift
class ConfigurationViewController: UIViewController {
    private let configurationManager = ConfigurationManager()
    private let configurationLabel = UILabel()
    private let loadButton = UIButton()
    private let resetButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConfigurationManager()
    }
    
    private func setupConfigurationManager() {
        let settings = ConfigurationSettings()
        settings.enableDynamicConfiguration = true
        settings.enableFeatureFlags = true
        settings.defaultConfigurationSource = .local
        configurationManager.configure(settings)
    }
    
    @objc private func loadButtonTapped() {
        configurationManager.loadConfiguration(from: .local) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let configuration):
                    self?.displayConfiguration(configuration)
                case .failure(let error):
                    self?.showError("Configuration loading failed: \(error)")
                }
            }
        }
    }
    
    @objc private func resetButtonTapped() {
        configurationManager.resetConfiguration { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.configurationLabel.text = "Configuration reset"
                case .failure(let error):
                    self?.showError("Configuration reset failed: \(error)")
                }
            }
        }
    }
    
    private func displayConfiguration(_ configuration: Configuration) {
        let text = """
        Configuration ID: \(configuration.id)
        Version: \(configuration.version)
        Environment: \(configuration.environment)
        Status: \(configuration.validationStatus)
        Values: \(configuration.values.count) items
        """
        
        configurationLabel.text = text
    }
}
```

## Testing

### Unit Tests

```swift
class ConfigurationTests: XCTestCase {
    var configurationManager: ConfigurationManager!
    
    override func setUp() {
        super.setUp()
        configurationManager = ConfigurationManager()
    }
    
    override func tearDown() {
        configurationManager = nil
        super.tearDown()
    }
    
    func testConfiguration() {
        let settings = ConfigurationSettings()
        settings.enableDynamicConfiguration = true
        settings.enableFeatureFlags = true
        
        configurationManager.configure(settings)
        
        // Verify configuration was applied
    }
    
    func testLoadConfiguration() {
        let expectation = XCTestExpectation(description: "Configuration loaded")
        
        configurationManager.loadConfiguration(from: .local) { result in
            switch result {
            case .success(let configuration):
                XCTAssertNotNil(configuration)
                XCTAssertFalse(configuration.id.isEmpty)
            case .failure(let error):
                XCTFail("Configuration loading failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetValue() {
        // Set a value
        let expectation = XCTestExpectation(description: "Value set")
        
        configurationManager.setValue("test_value", for: "test_key") { result in
            switch result {
            case .success:
                // Get the value
                let value = self.configurationManager.getValue(for: "test_key", defaultValue: "")
                XCTAssertEqual(value, "test_value")
            case .failure(let error):
                XCTFail("Value setting failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConfigurationValidation() {
        let configuration = Configuration(
            id: "test",
            version: "1.0",
            environment: "test",
            timestamp: Date(),
            values: [:],
            metadata: [:],
            validationStatus: .valid,
            source: .local
        )
        
        let validationResult = configurationManager.validateConfiguration(configuration)
        XCTAssertTrue(validationResult.isValid)
    }
}
```

## Best Practices

### 1. Configuration

- **Always configure the configuration manager before use**
- **Use appropriate configuration sources**
- **Enable validation for production environments**
- **Implement proper error handling**

### 2. Security

- **Encrypt sensitive configuration data**
- **Use secure storage for sensitive values**
- **Validate configuration from untrusted sources**
- **Implement access controls**

### 3. Performance

- **Cache configuration values when appropriate**
- **Use lazy loading for large configurations**
- **Optimize configuration validation**
- **Monitor configuration loading performance**

### 4. Reliability

- **Implement fallback configurations**
- **Use backup configuration sources**
- **Validate configuration before applying**
- **Handle configuration errors gracefully**

## Troubleshooting

### Common Issues

#### 1. Configuration Not Loading

**Problem**: Configuration fails to load from source.

**Solutions**:
- Check source availability
- Verify file permissions
- Check network connectivity
- Validate configuration format

#### 2. Validation Errors

**Problem**: Configuration validation fails.

**Solutions**:
- Check required keys
- Verify value types
- Fix format issues
- Resolve dependencies

#### 3. Encryption Issues

**Problem**: Configuration encryption/decryption fails.

**Solutions**:
- Verify encryption key
- Check keychain access
- Validate encryption algorithm
- Handle key rotation

#### 4. Performance Issues

**Problem**: Configuration operations are slow.

**Solutions**:
- Enable caching
- Optimize validation rules
- Use appropriate sources
- Implement lazy loading

### Debugging Tips

1. **Enable debug logging**:
```swift
let settings = ConfigurationSettings()
settings.enableDebugLogging = true
```

2. **Check configuration status**:
```swift
let validationResult = configurationManager.validateConfiguration(configuration)
if !validationResult.isValid {
    for error in validationResult.errors {
        print("Validation error: \(error.message)")
    }
}
```

3. **Export configuration for debugging**:
```swift
if let data = configurationManager.exportConfiguration() {
    let json = String(data: data, encoding: .utf8)
    print("Configuration: \(json ?? "")")
}
```

## Support

For additional support and documentation:

- [Getting Started Guide](GettingStarted.md)
- [Configuration Guide](ConfigurationGuide.md)
- [API Reference](API.md)
- [Examples](../Examples/ConfigurationExamples/)
- [GitHub Issues](https://github.com/muhittincamdali/GlobalLingo/issues)

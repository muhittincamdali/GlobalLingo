# Localization API

## Overview

The Localization API provides comprehensive localization capabilities for iOS applications, including multi-language support, dynamic language switching, pluralization rules, and gender-specific text adaptation.

## Core Classes

### LocalizationManager

The main localization manager that orchestrates all localization operations.

```swift
public class LocalizationManager {
    public init()
    public func configure(_ configuration: LocalizationConfiguration)
    public func addSupportedLanguages(_ languages: [String], completion: @escaping (Result<[Language], LocalizationError>) -> Void)
    public func setCurrentLanguage(_ languageCode: String, completion: @escaping (Result<Language, LocalizationError>) -> Void)
    public func getCurrentLanguage() -> Language?
    public func localizedString(key: String, language: String, completion: @escaping (Result<String, LocalizationError>) -> Void)
    public func localizedString(key: String, language: String, arguments: [CVarArg], completion: @escaping (Result<String, LocalizationError>) -> Void)
    public func switchLanguage(to languageCode: String, completion: @escaping (Result<Void, LocalizationError>) -> Void)
    public func getSupportedLanguages() -> [Language]
    public func isLanguageSupported(_ languageCode: String) -> Bool
}
```

### LocalizationConfiguration

Configuration options for the localization manager.

```swift
public struct LocalizationConfiguration {
    public var enableMultiLanguage: Bool
    public var enableDynamicSwitching: Bool
    public var enablePluralization: Bool
    public var enableGenderSpecific: Bool
    public var enableContextAware: Bool
    public var enableRegionalVariants: Bool
    public var enableFallbackLanguages: Bool
    public var enableLanguageDetection: Bool
    public var defaultLanguage: String
    public var fallbackLanguage: String
    public var bundleName: String
    public var tableName: String
}
```

### Language

Represents a supported language.

```swift
public struct Language {
    public let code: String
    public let name: String
    public let nativeName: String
    public let direction: TextDirection
    public let region: String?
    public let script: String?
    public let isRTL: Bool
    public let pluralizationRules: PluralizationRules
    public let dateFormat: DateFormat
    public let numberFormat: NumberFormat
}
```

### TextDirection

Enumeration of text directions.

```swift
public enum TextDirection {
    case leftToRight
    case rightToLeft
}
```

### PluralizationRules

Represents pluralization rules for a language.

```swift
public struct PluralizationRules {
    public let zero: String?
    public let one: String?
    public let two: String?
    public let few: String?
    public let many: String?
    public let other: String
    public let rule: PluralizationRule
}
```

### PluralizationRule

Enumeration of pluralization rule types.

```swift
public enum PluralizationRule {
    case zero
    case one
    case two
    case few
    case many
    case other
}
```

### DateFormat

Represents date formatting for a language.

```swift
public struct DateFormat {
    public let short: String
    public let medium: String
    public let long: String
    public let full: String
    public let timeZone: TimeZone
    public let calendar: Calendar
}
```

### NumberFormat

Represents number formatting for a language.

```swift
public struct NumberFormat {
    public let decimalSeparator: String
    public let thousandsSeparator: String
    public let currencySymbol: String
    public let currencyCode: String
    public let positiveFormat: String
    public let negativeFormat: String
}
```

### LocalizationError

Enumeration of localization error types.

```swift
public enum LocalizationError: Error {
    case invalidLanguageCode(String)
    case languageNotSupported(String)
    case keyNotFound(String)
    case bundleNotFound(String)
    case tableNotFound(String)
    case invalidArguments([CVarArg])
    case configurationError(String)
    case switchingFailed(String)
}
```

## Usage Examples

### Basic Localization

```swift
let localizationManager = LocalizationManager()

let config = LocalizationConfiguration()
config.enableMultiLanguage = true
config.enableDynamicSwitching = true
config.defaultLanguage = "en"
config.fallbackLanguage = "en"

localizationManager.configure(config)

// Add supported languages
localizationManager.addSupportedLanguages([
    "en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko"
]) { result in
    switch result {
    case .success(let languages):
        print("Supported languages: \(languages.count)")
    case .failure(let error):
        print("Failed to add languages: \(error)")
    }
}

// Get localized string
localizationManager.localizedString(
    key: "welcome_message",
    language: "es"
) { result in
    switch result {
    case .success(let string):
        print("Localized string: \(string)")
    case .failure(let error):
        print("Localization failed: \(error)")
    }
}
```

### Dynamic Language Switching

```swift
// Switch language dynamically
localizationManager.switchLanguage(to: "fr") { result in
    switch result {
    case .success:
        print("Language switched to French")
        
        // Get string in new language
        localizationManager.localizedString(
            key: "hello_world",
            language: "fr"
        ) { result in
            switch result {
            case .success(let string):
                print("French: \(string)")
            case .failure(let error):
                print("Failed: \(error)")
            }
        }
    case .failure(let error):
        print("Language switching failed: \(error)")
    }
}
```

### String with Arguments

```swift
// Localized string with arguments
localizationManager.localizedString(
    key: "user_greeting",
    language: "es",
    arguments: ["John", 25]
) { result in
    switch result {
    case .success(let string):
        print("Greeting: \(string)")
    case .failure(let error):
        print("Failed: \(error)")
    }
}
```

### Pluralization

```swift
// Get pluralized string
let pluralizationManager = PluralizationManager()

pluralizationManager.pluralizedString(
    key: "item_count",
    count: 5,
    language: "en"
) { result in
    switch result {
    case .success(let string):
        print("Pluralized: \(string)")
    case .failure(let error):
        print("Pluralization failed: \(error)")
    }
}
```

## Advanced Features

### Context-Aware Localization

```swift
public protocol ContextAwareLocalization {
    func localizedString(key: String, context: String, language: String) -> String
    func setContext(_ context: String, forLanguage: String)
    func clearContext(forLanguage: String)
}
```

### Regional Variants

```swift
public protocol RegionalVariantSupport {
    func getRegionalVariant(forLanguage: String, region: String) -> Language?
    func setRegionalVariant(_ variant: Language, forLanguage: String)
    func getAvailableVariants(forLanguage: String) -> [Language]
}
```

### Language Detection

```swift
public protocol LanguageDetection {
    func detectLanguage(for text: String) -> String?
    func detectLanguageConfidence(for text: String) -> [String: Double]
    func setDetectionThreshold(_ threshold: Double)
}
```

### Fallback System

```swift
public protocol FallbackSystem {
    func setFallbackChain(_ chain: [String])
    func getFallbackChain() -> [String]
    func addFallbackLanguage(_ language: String, after: String)
    func removeFallbackLanguage(_ language: String)
}
```

## Performance Optimization

### Caching

Localization results are cached to improve performance.

```swift
public protocol LocalizationCache {
    func cache(string: String, forKey: String, language: String)
    func retrieve(forKey: String, language: String) -> String?
    func clear()
    func clear(forLanguage: String)
    func clearExpired()
}
```

### Preloading

Preload localization data for better performance.

```swift
public protocol LocalizationPreloader {
    func preloadLanguage(_ language: String, completion: @escaping (Result<Void, LocalizationError>) -> Void)
    func preloadLanguages(_ languages: [String], completion: @escaping (Result<Void, LocalizationError>) -> Void)
    func isPreloaded(_ language: String) -> Bool
    func clearPreloadedData()
}
```

## Integration Examples

### SwiftUI Integration

```swift
struct LocalizedView: View {
    @StateObject private var localizationManager = LocalizationManager()
    @State private var currentLanguage = "en"
    @State private var welcomeText = ""
    
    var body: some View {
        VStack {
            Text(welcomeText)
                .font(.title)
                .padding()
            
            Picker("Language", selection: $currentLanguage) {
                Text("English").tag("en")
                Text("Español").tag("es")
                Text("Français").tag("fr")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: currentLanguage) { newLanguage in
                switchLanguage(to: newLanguage)
            }
        }
        .onAppear {
            setupLocalization()
        }
    }
    
    private func setupLocalization() {
        let config = LocalizationConfiguration()
        config.enableMultiLanguage = true
        config.enableDynamicSwitching = true
        localizationManager.configure(config)
        
        localizationManager.addSupportedLanguages(["en", "es", "fr"]) { _ in
            loadWelcomeText()
        }
    }
    
    private func switchLanguage(to language: String) {
        localizationManager.switchLanguage(to: language) { _ in
            loadWelcomeText()
        }
    }
    
    private func loadWelcomeText() {
        localizationManager.localizedString(
            key: "welcome_message",
            language: currentLanguage
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    welcomeText = text
                case .failure:
                    welcomeText = "Welcome"
                }
            }
        }
    }
}
```

### UIKit Integration

```swift
class LocalizedViewController: UIViewController {
    private let localizationManager = LocalizationManager()
    private let welcomeLabel = UILabel()
    private let languageSegmentedControl = UISegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocalization()
    }
    
    private func setupLocalization() {
        let config = LocalizationConfiguration()
        config.enableMultiLanguage = true
        config.enableDynamicSwitching = true
        localizationManager.configure(config)
        
        localizationManager.addSupportedLanguages(["en", "es", "fr"]) { [weak self] _ in
            self?.loadWelcomeText()
        }
    }
    
    @objc private func languageChanged() {
        let selectedLanguage = ["en", "es", "fr"][languageSegmentedControl.selectedSegmentIndex]
        
        localizationManager.switchLanguage(to: selectedLanguage) { [weak self] _ in
            self?.loadWelcomeText()
        }
    }
    
    private func loadWelcomeText() {
        let currentLanguage = ["en", "es", "fr"][languageSegmentedControl.selectedSegmentIndex]
        
        localizationManager.localizedString(
            key: "welcome_message",
            language: currentLanguage
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    self?.welcomeLabel.text = text
                case .failure:
                    self?.welcomeLabel.text = "Welcome"
                }
            }
        }
    }
}
```

## Testing

### Unit Tests

```swift
class LocalizationManagerTests: XCTestCase {
    var localizationManager: LocalizationManager!
    
    override func setUp() {
        super.setUp()
        localizationManager = LocalizationManager()
    }
    
    override func tearDown() {
        localizationManager = nil
        super.tearDown()
    }
    
    func testConfiguration() {
        let config = LocalizationConfiguration()
        config.enableMultiLanguage = true
        config.defaultLanguage = "en"
        
        localizationManager.configure(config)
        
        // Verify configuration was applied
        // Add assertions based on your implementation
    }
    
    func testAddSupportedLanguages() {
        let expectation = XCTestExpectation(description: "Languages added")
        
        localizationManager.addSupportedLanguages(["en", "es"]) { result in
            switch result {
            case .success(let languages):
                XCTAssertEqual(languages.count, 2)
                XCTAssertTrue(languages.contains { $0.code == "en" })
                XCTAssertTrue(languages.contains { $0.code == "es" })
            case .failure(let error):
                XCTFail("Failed to add languages: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLocalizedString() {
        let expectation = XCTestExpectation(description: "String localized")
        
        localizationManager.localizedString(
            key: "test_key",
            language: "en"
        ) { result in
            switch result {
            case .success(let string):
                XCTAssertFalse(string.isEmpty)
            case .failure(let error):
                // Handle expected errors for missing keys
                XCTAssertEqual(error, .keyNotFound("test_key"))
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
```

## Best Practices

1. **Always configure the localization manager before use**
2. **Use appropriate language codes (ISO 639-1)**
3. **Implement proper error handling for all localization operations**
4. **Cache frequently used strings for better performance**
5. **Use pluralization rules correctly for each language**
6. **Provide fallback languages for better user experience**
7. **Test localization with different language combinations**
8. **Use context-aware localization when appropriate**
9. **Handle RTL languages properly**
10. **Monitor localization performance and optimize as needed**

## Migration Guide

### From Version 1.0 to 2.0

1. **Update configuration initialization**
2. **Replace deprecated methods**
3. **Update error handling**
4. **Migrate to new API structure**

### Breaking Changes

- `LocalizationManager.init()` now requires configuration
- Error types have been reorganized
- Some method signatures have changed

## Troubleshooting

### Common Issues

1. **Missing localization files**
2. **Invalid language codes**
3. **Configuration errors**
4. **Performance issues**
5. **RTL layout problems**

### Solutions

1. **Verify localization bundle structure**
2. **Check language code format**
3. **Validate configuration settings**
4. **Implement caching and preloading**
5. **Test RTL layout thoroughly**

## Support

For additional support and documentation:

- [Getting Started Guide](GettingStarted.md)
- [Localization Guide](LocalizationGuide.md)
- [API Reference](API.md)
- [Examples](../Examples/LocalizationExamples/)
- [GitHub Issues](https://github.com/muhittincamdali/GlobalLingo/issues)

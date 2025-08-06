# Localization Guide

## Overview

This comprehensive guide will walk you through setting up and using the GlobalLingo localization framework in your iOS applications. You'll learn how to implement multi-language support, dynamic language switching, pluralization, and cultural adaptations.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Basic Setup](#basic-setup)
4. [Language Configuration](#language-configuration)
5. [String Localization](#string-localization)
6. [Dynamic Language Switching](#dynamic-language-switching)
7. [Pluralization](#pluralization)
8. [Gender-Specific Text](#gender-specific-text)
9. [Context-Aware Localization](#context-aware-localization)
10. [Regional Variants](#regional-variants)
11. [Fallback System](#fallback-system)
12. [Testing](#testing)
13. [Best Practices](#best-practices)
14. [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have:

- **iOS 15.0+** with iOS 15.0+ SDK
- **Swift 5.9+** programming language
- **Xcode 15.0+** development environment
- **Swift Package Manager** for dependency management
- **Basic understanding of iOS development**

## Installation

### Swift Package Manager

Add GlobalLingo to your project using Swift Package Manager:

1. In Xcode, go to **File > Add Package Dependencies**
2. Enter the repository URL: `https://github.com/muhittincamdali/GlobalLingo.git`
3. Select the version you want to use
4. Click **Add Package**

### Manual Installation

If you prefer manual installation:

```bash
# Clone the repository
git clone https://github.com/muhittincamdali/GlobalLingo.git

# Navigate to project directory
cd GlobalLingo

# Install dependencies
swift package resolve
```

## Basic Setup

### 1. Import the Framework

```swift
import GlobalLingo
```

### 2. Initialize the Localization Manager

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    let localizationManager = LocalizationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure localization
        setupLocalization()
        
        return true
    }
    
    private func setupLocalization() {
        let config = LocalizationConfiguration()
        config.enableMultiLanguage = true
        config.enableDynamicSwitching = true
        config.enablePluralization = true
        config.enableGenderSpecific = true
        config.defaultLanguage = "en"
        config.fallbackLanguage = "en"
        
        localizationManager.configure(config)
        
        // Add supported languages
        localizationManager.addSupportedLanguages([
            "en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko"
        ]) { result in
            switch result {
            case .success(let languages):
                print("✅ Supported languages added: \(languages.count)")
            case .failure(let error):
                print("❌ Failed to add languages: \(error)")
            }
        }
    }
}
```

### 3. Set Initial Language

```swift
// Set the initial language based on user preferences or device settings
let preferredLanguage = Locale.current.languageCode ?? "en"
localizationManager.setCurrentLanguage(preferredLanguage) { result in
    switch result {
    case .success(let language):
        print("✅ Language set to: \(language.name)")
    case .failure(let error):
        print("❌ Failed to set language: \(error)")
    }
}
```

## Language Configuration

### Supported Languages

GlobalLingo supports 100+ languages. Here are some commonly used language codes:

```swift
let commonLanguages = [
    "en", // English
    "es", // Spanish
    "fr", // French
    "de", // German
    "it", // Italian
    "pt", // Portuguese
    "ru", // Russian
    "zh", // Chinese (Simplified)
    "ja", // Japanese
    "ko", // Korean
    "ar", // Arabic
    "he", // Hebrew
    "hi", // Hindi
    "tr", // Turkish
    "nl", // Dutch
    "sv", // Swedish
    "da", // Danish
    "no", // Norwegian
    "fi", // Finnish
    "pl"  // Polish
]
```

### Language Properties

Each language has specific properties:

```swift
struct Language {
    let code: String           // ISO 639-1 language code
    let name: String           // Language name in English
    let nativeName: String     // Language name in native script
    let direction: TextDirection // Text direction (LTR/RTL)
    let region: String?        // Region code (optional)
    let script: String?        // Script code (optional)
    let isRTL: Bool           // Whether it's a right-to-left language
    let pluralizationRules: PluralizationRules
    let dateFormat: DateFormat
    let numberFormat: NumberFormat
}
```

## String Localization

### Basic String Localization

```swift
// Get a localized string
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

### String with Arguments

```swift
// Localized string with format arguments
localizationManager.localizedString(
    key: "user_greeting",
    language: "fr",
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

### SwiftUI Integration

```swift
struct LocalizedTextView: View {
    @StateObject private var localizationManager = LocalizationManager()
    @State private var localizedText = ""
    
    var body: some View {
        VStack {
            Text(localizedText)
                .font(.title)
                .padding()
            
            Button("Load Localized Text") {
                loadLocalizedText()
            }
        }
        .onAppear {
            setupLocalization()
        }
    }
    
    private func setupLocalization() {
        let config = LocalizationConfiguration()
        config.enableMultiLanguage = true
        localizationManager.configure(config)
        
        localizationManager.addSupportedLanguages(["en", "es", "fr"]) { _ in
            loadLocalizedText()
        }
    }
    
    private func loadLocalizedText() {
        localizationManager.localizedString(
            key: "hello_world",
            language: "es"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    localizedText = text
                case .failure:
                    localizedText = "Hello World"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocalization()
    }
    
    private func setupLocalization() {
        let config = LocalizationConfiguration()
        config.enableMultiLanguage = true
        localizationManager.configure(config)
        
        localizationManager.addSupportedLanguages(["en", "es", "fr"]) { [weak self] _ in
            self?.loadLocalizedText()
        }
    }
    
    private func loadLocalizedText() {
        localizationManager.localizedString(
            key: "welcome_message",
            language: "es"
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

## Dynamic Language Switching

### Switch Language at Runtime

```swift
// Switch language dynamically
localizationManager.switchLanguage(to: "fr") { result in
    switch result {
    case .success:
        print("✅ Language switched to French")
        
        // Reload UI with new language
        reloadUserInterface()
        
    case .failure(let error):
        print("❌ Language switching failed: \(error)")
    }
}
```

### Language Selection UI

```swift
struct LanguageSelectionView: View {
    @StateObject private var localizationManager = LocalizationManager()
    @State private var selectedLanguage = "en"
    
    let languages = [
        ("English", "en"),
        ("Español", "es"),
        ("Français", "fr"),
        ("Deutsch", "de"),
        ("Italiano", "it")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Language")
                .font(.title)
            
            ForEach(languages, id: \.1) { language in
                Button(language.0) {
                    switchLanguage(to: language.1)
                }
                .buttonStyle(.bordered)
                .background(selectedLanguage == language.1 ? Color.blue : Color.clear)
                .foregroundColor(selectedLanguage == language.1 ? .white : .primary)
            }
        }
        .padding()
        .onAppear {
            setupLocalization()
        }
    }
    
    private func setupLocalization() {
        let config = LocalizationConfiguration()
        config.enableMultiLanguage = true
        config.enableDynamicSwitching = true
        localizationManager.configure(config)
        
        localizationManager.addSupportedLanguages(languages.map { $0.1 }) { _ in }
    }
    
    private func switchLanguage(to language: String) {
        localizationManager.switchLanguage(to: language) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    selectedLanguage = language
                    // Notify app to reload UI
                    NotificationCenter.default.post(name: .languageChanged, object: language)
                case .failure(let error):
                    print("Language switching failed: \(error)")
                }
            }
        }
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
```

## Pluralization

### Basic Pluralization

```swift
let pluralizationManager = PluralizationManager()

// Configure pluralization
let config = PluralizationConfiguration()
config.enableAdvancedRules = true
config.enableGenderSpecific = true
pluralizationManager.configure(config)

// Get pluralized string
pluralizationManager.pluralizedString(
    key: "item_count",
    count: 5,
    language: "en"
) { result in
    switch result {
    case .success(let string):
        print("Pluralized: \(string)") // "5 items"
    case .failure(let error):
        print("Pluralization failed: \(error)")
    }
}
```

### Complex Pluralization Rules

Different languages have different pluralization rules:

```swift
// English: 1 item, 2 items, 0 items
pluralizationManager.pluralizedString(key: "item_count", count: 1, language: "en") // "1 item"
pluralizationManager.pluralizedString(key: "item_count", count: 2, language: "en") // "2 items"
pluralizationManager.pluralizedString(key: "item_count", count: 0, language: "en") // "0 items"

// Russian: 1 элемент, 2 элемента, 5 элементов
pluralizationManager.pluralizedString(key: "item_count", count: 1, language: "ru") // "1 элемент"
pluralizationManager.pluralizedString(key: "item_count", count: 2, language: "ru") // "2 элемента"
pluralizationManager.pluralizedString(key: "item_count", count: 5, language: "ru") // "5 элементов"

// Arabic: 1 عنصر، 2 عنصران، 3 عناصر
pluralizationManager.pluralizedString(key: "item_count", count: 1, language: "ar") // "1 عنصر"
pluralizationManager.pluralizedString(key: "item_count", count: 2, language: "ar") // "2 عنصران"
pluralizationManager.pluralizedString(key: "item_count", count: 3, language: "ar") // "3 عناصر"
```

## Gender-Specific Text

### Gender-Aware Localization

```swift
// Get gender-specific string
pluralizationManager.genderSpecificString(
    key: "user_greeting",
    gender: .male,
    language: "es"
) { result in
    switch result {
    case .success(let string):
        print("Male greeting: \(string)") // "Bienvenido"
    case .failure(let error):
        print("Gender-specific string failed: \(error)")
    }
}

pluralizationManager.genderSpecificString(
    key: "user_greeting",
    gender: .female,
    language: "es"
) { result in
    switch result {
    case .success(let string):
        print("Female greeting: \(string)") // "Bienvenida"
    case .failure(let error):
        print("Gender-specific string failed: \(error)")
    }
}
```

## Context-Aware Localization

### Context-Sensitive Translation

```swift
// Get context-aware localized string
localizationManager.localizedString(
    key: "save",
    context: "button",
    language: "fr"
) { result in
    switch result {
    case .success(let string):
        print("Save button: \(string)") // "Enregistrer"
    case .failure(let error):
        print("Context-aware localization failed: \(error)")
    }
}

localizationManager.localizedString(
    key: "save",
    context: "file_menu",
    language: "fr"
) { result in
    switch result {
    case .success(let string):
        print("Save menu item: \(string)") // "Sauvegarder"
    case .failure(let error):
        print("Context-aware localization failed: \(error)")
    }
}
```

## Regional Variants

### Regional Language Support

```swift
// Get regional variant
let regionalManager = RegionalVariantManager()

regionalManager.getRegionalVariant(
    forLanguage: "en",
    region: "US"
) { result in
    switch result {
    case .success(let variant):
        print("US English variant: \(variant.name)")
    case .failure(let error):
        print("Failed to get regional variant: \(error)")
    }
}

regionalManager.getRegionalVariant(
    forLanguage: "en",
    region: "GB"
) { result in
    switch result {
    case .success(let variant):
        print("British English variant: \(variant.name)")
    case .failure(let error):
        print("Failed to get regional variant: \(error)")
    }
}
```

## Fallback System

### Intelligent Fallback

```swift
// Configure fallback chain
let fallbackManager = FallbackManager()

fallbackManager.setFallbackChain([
    "es-MX", // Mexican Spanish
    "es",    // Spanish
    "en"     // English
])

// When a string is not found in es-MX, it will fall back to es, then to en
localizationManager.localizedString(
    key: "missing_key",
    language: "es-MX"
) { result in
    switch result {
    case .success(let string):
        print("Found in fallback: \(string)")
    case .failure(let error):
        print("Not found in any fallback: \(error)")
    }
}
```

## Testing

### Unit Tests

```swift
class LocalizationTests: XCTestCase {
    var localizationManager: LocalizationManager!
    
    override func setUp() {
        super.setUp()
        localizationManager = LocalizationManager()
    }
    
    override func tearDown() {
        localizationManager = nil
        super.tearDown()
    }
    
    func testLanguageConfiguration() {
        let config = LocalizationConfiguration()
        config.enableMultiLanguage = true
        config.defaultLanguage = "en"
        
        localizationManager.configure(config)
        
        // Verify configuration
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
    
    func testLanguageSwitching() {
        let expectation = XCTestExpectation(description: "Language switched")
        
        localizationManager.switchLanguage(to: "es") { result in
            switch result {
            case .success:
                // Language switched successfully
                break
            case .failure(let error):
                XCTFail("Language switching failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
```

### UI Tests

```swift
class LocalizationUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testLanguageSelection() {
        // Navigate to language selection
        app.buttons["Settings"].tap()
        app.buttons["Language"].tap()
        
        // Select Spanish
        app.buttons["Español"].tap()
        
        // Verify UI updated
        XCTAssertTrue(app.staticTexts["Bienvenido"].exists)
    }
    
    func testDynamicLanguageSwitching() {
        // Test switching language without app restart
        app.buttons["Settings"].tap()
        app.buttons["Language"].tap()
        app.buttons["Français"].tap()
        
        // Verify immediate UI update
        XCTAssertTrue(app.staticTexts["Bienvenue"].exists)
    }
}
```

## Best Practices

### 1. Configuration

- **Always configure the localization manager before use**
- **Set appropriate default and fallback languages**
- **Enable only the features you need**

### 2. Language Codes

- **Use ISO 639-1 language codes (e.g., "en", "es", "fr")**
- **Use ISO 3166-1 region codes for regional variants (e.g., "en-US", "en-GB")**
- **Validate language codes before use**

### 3. String Keys

- **Use descriptive, hierarchical keys (e.g., "user.profile.welcome")**
- **Keep keys consistent across languages**
- **Use lowercase with underscores for key names**

### 4. Error Handling

- **Always handle localization errors gracefully**
- **Provide fallback text for missing translations**
- **Log localization errors for debugging**

### 5. Performance

- **Cache frequently used strings**
- **Preload language data when possible**
- **Use batch operations for multiple strings**

### 6. Testing

- **Test with all supported languages**
- **Test language switching functionality**
- **Test pluralization rules**
- **Test RTL languages thoroughly**

### 7. Accessibility

- **Ensure localized text is accessible**
- **Test with VoiceOver and other accessibility features**
- **Provide appropriate accessibility labels**

### 8. Cultural Considerations

- **Respect cultural differences in text length**
- **Consider cultural sensitivities**
- **Adapt UI layout for different languages**

## Troubleshooting

### Common Issues

#### 1. Strings Not Found

**Problem**: Localized strings are not found or return empty.

**Solutions**:
- Verify string keys exist in localization files
- Check language codes are correct
- Ensure localization files are included in the app bundle
- Verify fallback language is configured

#### 2. Language Switching Not Working

**Problem**: Language switching doesn't update the UI.

**Solutions**:
- Ensure dynamic language switching is enabled
- Verify UI components are listening for language change notifications
- Check that language switching is called on the main thread
- Verify the new language is supported

#### 3. Pluralization Issues

**Problem**: Pluralization rules are not working correctly.

**Solutions**:
- Verify pluralization rules are defined for the language
- Check that the count parameter is correct
- Ensure pluralization is enabled in configuration
- Test with different count values

#### 4. RTL Layout Problems

**Problem**: Right-to-left languages don't display correctly.

**Solutions**:
- Enable RTL support in configuration
- Use semantic content attributes
- Test with actual RTL languages
- Verify layout constraints work in both directions

#### 5. Performance Issues

**Problem**: Localization is slow or causing performance problems.

**Solutions**:
- Enable caching for frequently used strings
- Preload language data
- Use batch operations
- Monitor memory usage

### Debugging Tips

1. **Enable debug logging**:
```swift
let config = LocalizationConfiguration()
config.enableDebugLogging = true
```

2. **Check current language**:
```swift
if let currentLanguage = localizationManager.getCurrentLanguage() {
    print("Current language: \(currentLanguage.code)")
}
```

3. **Verify supported languages**:
```swift
let supportedLanguages = localizationManager.getSupportedLanguages()
print("Supported languages: \(supportedLanguages.map { $0.code })")
```

4. **Test fallback system**:
```swift
// Try to get a string that doesn't exist
localizationManager.localizedString(
    key: "nonexistent_key",
    language: "es"
) { result in
    switch result {
    case .success(let string):
        print("Found in fallback: \(string)")
    case .failure(let error):
        print("Not found: \(error)")
    }
}
```

## Support

For additional support and documentation:

- [API Reference](LocalizationAPI.md)
- [Examples](../Examples/LocalizationExamples/)
- [GitHub Issues](https://github.com/muhittincamdali/GlobalLingo/issues)
- [Community Discussions](https://github.com/muhittincamdali/GlobalLingo/discussions)

## Next Steps

Now that you have a solid understanding of localization with GlobalLingo, you can:

1. **Explore advanced features** like cultural adaptation and RTL support
2. **Implement translation capabilities** for dynamic content
3. **Add performance monitoring** to track localization performance
4. **Contribute to the project** by reporting issues or submitting pull requests
5. **Share your experience** with the community

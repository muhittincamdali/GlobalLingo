# Translation API

<!-- TOC START -->
## Table of Contents
- [Translation API](#translation-api)
- [Overview](#overview)
- [Core Classes](#core-classes)
  - [TranslationManager](#translationmanager)
  - [TranslationConfiguration](#translationconfiguration)
  - [Translation](#translation)
  - [ContextualTranslation](#contextualtranslation)
  - [TranslationQuality](#translationquality)
  - [TranslationFeedback](#translationfeedback)
  - [TranslationError](#translationerror)
- [Usage Examples](#usage-examples)
  - [Basic Translation](#basic-translation)
  - [Batch Translation](#batch-translation)
  - [Context-Aware Translation](#context-aware-translation)
  - [Translation Improvement](#translation-improvement)
- [Advanced Features](#advanced-features)
  - [Translation Memory](#translation-memory)
  - [Quality Assurance](#quality-assurance)
  - [Collaborative Translation](#collaborative-translation)
- [Performance Optimization](#performance-optimization)
  - [Caching](#caching)
  - [Batch Processing](#batch-processing)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [Integration Examples](#integration-examples)
  - [SwiftUI Integration](#swiftui-integration)
  - [UIKit Integration](#uikit-integration)
- [Testing](#testing)
  - [Unit Tests](#unit-tests)
- [Migration Guide](#migration-guide)
  - [From Version 1.0 to 2.0](#from-version-10-to-20)
  - [Breaking Changes](#breaking-changes)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Solutions](#solutions)
- [Support](#support)
<!-- TOC END -->


## Overview

The Translation API provides comprehensive translation capabilities for iOS applications, including AI-powered translation, machine learning, human review, and translation memory management.

## Core Classes

### TranslationManager

The main translation manager that orchestrates all translation operations.

```swift
public class TranslationManager {
    public init()
    public func configure(_ configuration: TranslationConfiguration)
    public func translateText(text: String, fromLanguage: String, toLanguage: String, completion: @escaping (Result<Translation, TranslationError>) -> Void)
    public func batchTranslate(texts: [String], fromLanguage: String, toLanguage: String, completion: @escaping (Result<[Translation], TranslationError>) -> Void)
    public func translateWithContext(text: String, context: String, fromLanguage: String, toLanguage: String, completion: @escaping (Result<ContextualTranslation, TranslationError>) -> Void)
    public func improveTranslation(original: String, translation: String, feedback: TranslationFeedback, language: String, completion: @escaping (Result<Void, TranslationError>) -> Void)
}
```

### TranslationConfiguration

Configuration options for the translation manager.

```swift
public struct TranslationConfiguration {
    public var enableAITranslation: Bool
    public var enableMachineLearning: Bool
    public var enableHumanReview: Bool
    public var enableTranslationMemory: Bool
    public var enableQualityAssurance: Bool
    public var enableCollaborativeTranslation: Bool
    public var enableVersionControl: Bool
    public var enableTranslationAnalytics: Bool
    public var maxBatchSize: Int
    public var timeoutInterval: TimeInterval
    public var retryCount: Int
    public var qualityThreshold: Double
}
```

### Translation

Represents a translation result.

```swift
public struct Translation {
    public let original: String
    public let translated: String
    public let fromLanguage: String
    public let toLanguage: String
    public let confidence: Double
    public let quality: TranslationQuality
    public let timestamp: Date
    public let metadata: [String: Any]
}
```

### ContextualTranslation

Represents a context-aware translation result.

```swift
public struct ContextualTranslation {
    public let original: String
    public let translated: String
    public let context: String
    public let fromLanguage: String
    public let toLanguage: String
    public let confidence: Double
    public let qualityScore: Double
    public let contextRelevance: Double
    public let timestamp: Date
}
```

### TranslationQuality

Enumeration of translation quality levels.

```swift
public enum TranslationQuality {
    case excellent
    case good
    case fair
    case poor
    case unacceptable
}
```

### TranslationFeedback

Enumeration of translation feedback types.

```swift
public enum TranslationFeedback {
    case positive
    case negative
    case neutral
    case correction(String)
}
```

### TranslationError

Enumeration of translation error types.

```swift
public enum TranslationError: Error {
    case invalidLanguage(String)
    case networkError(Error)
    case timeout
    case invalidText
    case translationFailed(String)
    case configurationError(String)
    case memoryError(String)
    case qualityThresholdNotMet
}
```

## Usage Examples

### Basic Translation

```swift
let translationManager = TranslationManager()

let config = TranslationConfiguration()
config.enableAITranslation = true
config.enableMachineLearning = true
config.timeoutInterval = 30.0
config.retryCount = 3

translationManager.configure(config)

translationManager.translateText(
    text: "Hello world",
    fromLanguage: "en",
    toLanguage: "es"
) { result in
    switch result {
    case .success(let translation):
        print("Translated: \(translation.translated)")
        print("Confidence: \(translation.confidence)%")
        print("Quality: \(translation.quality)")
    case .failure(let error):
        print("Translation failed: \(error)")
    }
}
```

### Batch Translation

```swift
let texts = [
    "Welcome to our app",
    "Thank you for using our service",
    "Please rate your experience"
]

translationManager.batchTranslate(
    texts: texts,
    fromLanguage: "en",
    toLanguage: "fr"
) { result in
    switch result {
    case .success(let translations):
        for translation in translations {
            print("Original: \(translation.original)")
            print("Translated: \(translation.translated)")
            print("---")
        }
    case .failure(let error):
        print("Batch translation failed: \(error)")
    }
}
```

### Context-Aware Translation

```swift
translationManager.translateWithContext(
    text: "I love this app",
    context: "user_feedback",
    fromLanguage: "en",
    toLanguage: "de"
) { result in
    switch result {
    case .success(let translation):
        print("Context-aware translation: \(translation.translated)")
        print("Quality score: \(translation.qualityScore)")
        print("Context relevance: \(translation.contextRelevance)")
    case .failure(let error):
        print("Context-aware translation failed: \(error)")
    }
}
```

### Translation Improvement

```swift
translationManager.improveTranslation(
    original: "Hello world",
    translation: "Hola mundo",
    feedback: .positive,
    language: "es"
) { result in
    switch result {
    case .success:
        print("Translation quality improved")
    case .failure(let error):
        print("Improvement failed: \(error)")
    }
}
```

## Advanced Features

### Translation Memory

The translation memory system stores and retrieves previous translations to improve consistency and speed.

```swift
public protocol TranslationMemory {
    func store(translation: Translation)
    func retrieve(original: String, fromLanguage: String, toLanguage: String) -> Translation?
    func clear()
    func export() -> Data
    func import(data: Data) throws
}
```

### Quality Assurance

Quality assurance features ensure translation accuracy and consistency.

```swift
public protocol TranslationQualityAssurance {
    func validate(translation: Translation) -> QualityValidationResult
    func suggestImprovements(translation: Translation) -> [TranslationSuggestion]
    func checkConsistency(translations: [Translation]) -> ConsistencyReport
}
```

### Collaborative Translation

Support for team-based translation workflows.

```swift
public protocol CollaborativeTranslation {
    func assignTranslation(task: TranslationTask, to: Translator)
    func reviewTranslation(translation: Translation, by: Reviewer)
    func approveTranslation(translation: Translation, by: Approver)
    func rejectTranslation(translation: Translation, reason: String)
}
```

## Performance Optimization

### Caching

Translation results are cached to improve performance.

```swift
public protocol TranslationCache {
    func cache(translation: Translation, for: String)
    func retrieve(for: String) -> Translation?
    func clear()
    func clearExpired()
}
```

### Batch Processing

Efficient batch processing for multiple translations.

```swift
public protocol BatchTranslationProcessor {
    func processBatch(texts: [String], fromLanguage: String, toLanguage: String) -> [Translation]
    func optimizeBatchSize(for: [String]) -> Int
    func estimateProcessingTime(for: [String]) -> TimeInterval
}
```

## Error Handling

Comprehensive error handling for all translation operations.

```swift
public extension TranslationError {
    var localizedDescription: String {
        switch self {
        case .invalidLanguage(let language):
            return "Invalid language code: \(language)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Translation request timed out"
        case .invalidText:
            return "Invalid text for translation"
        case .translationFailed(let reason):
            return "Translation failed: \(reason)"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .memoryError(let message):
            return "Memory error: \(message)"
        case .qualityThresholdNotMet:
            return "Translation quality below threshold"
        }
    }
}
```

## Best Practices

1. **Always configure the translation manager before use**
2. **Use appropriate timeout intervals for network requests**
3. **Implement proper error handling for all translation operations**
4. **Use batch translation for multiple texts to improve performance**
5. **Provide context when available for better translation quality**
6. **Store and reuse translations when possible**
7. **Monitor translation quality and provide feedback**
8. **Use appropriate language codes (ISO 639-1)**
9. **Handle network connectivity issues gracefully**
10. **Implement retry logic for failed translations**

## Integration Examples

### SwiftUI Integration

```swift
struct TranslationView: View {
    @StateObject private var translationManager = TranslationManager()
    @State private var originalText = ""
    @State private var translatedText = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            TextField("Enter text to translate", text: $originalText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Translate") {
                translateText()
            }
            .disabled(originalText.isEmpty || isLoading)
            
            if isLoading {
                ProgressView()
            } else {
                Text(translatedText)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            setupTranslationManager()
        }
    }
    
    private func setupTranslationManager() {
        let config = TranslationConfiguration()
        config.enableAITranslation = true
        translationManager.configure(config)
    }
    
    private func translateText() {
        isLoading = true
        
        translationManager.translateText(
            text: originalText,
            fromLanguage: "en",
            toLanguage: "es"
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let translation):
                    translatedText = translation.translated
                case .failure(let error):
                    translatedText = "Translation failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
```

### UIKit Integration

```swift
class TranslationViewController: UIViewController {
    private let translationManager = TranslationManager()
    private let textField = UITextField()
    private let translateButton = UIButton()
    private let resultLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTranslationManager()
    }
    
    private func setupTranslationManager() {
        let config = TranslationConfiguration()
        config.enableAITranslation = true
        config.timeoutInterval = 30.0
        translationManager.configure(config)
    }
    
    @objc private func translateButtonTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        
        activityIndicator.startAnimating()
        translateButton.isEnabled = false
        
        translationManager.translateText(
            text: text,
            fromLanguage: "en",
            toLanguage: "es"
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.translateButton.isEnabled = true
                
                switch result {
                case .success(let translation):
                    self?.resultLabel.text = translation.translated
                case .failure(let error):
                    self?.resultLabel.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
```

## Testing

### Unit Tests

```swift
class TranslationManagerTests: XCTestCase {
    var translationManager: TranslationManager!
    
    override func setUp() {
        super.setUp()
        translationManager = TranslationManager()
    }
    
    override func tearDown() {
        translationManager = nil
        super.tearDown()
    }
    
    func testTranslationConfiguration() {
        let config = TranslationConfiguration()
        config.enableAITranslation = true
        config.timeoutInterval = 30.0
        
        translationManager.configure(config)
        
        // Verify configuration was applied
        // Add assertions based on your implementation
    }
    
    func testTranslationSuccess() {
        let expectation = XCTestExpectation(description: "Translation completed")
        
        translationManager.translateText(
            text: "Hello",
            fromLanguage: "en",
            toLanguage: "es"
        ) { result in
            switch result {
            case .success(let translation):
                XCTAssertEqual(translation.fromLanguage, "en")
                XCTAssertEqual(translation.toLanguage, "es")
                XCTAssertFalse(translation.translated.isEmpty)
            case .failure(let error):
                XCTFail("Translation failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testTranslationError() {
        let expectation = XCTestExpectation(description: "Translation error")
        
        translationManager.translateText(
            text: "",
            fromLanguage: "en",
            toLanguage: "es"
        ) { result in
            switch result {
            case .success:
                XCTFail("Should have failed with empty text")
            case .failure(let error):
                XCTAssertEqual(error, .invalidText)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
```

## Migration Guide

### From Version 1.0 to 2.0

1. **Update configuration initialization**
2. **Replace deprecated methods**
3. **Update error handling**
4. **Migrate to new API structure**

### Breaking Changes

- `TranslationManager.init()` now requires configuration
- Error types have been reorganized
- Some method signatures have changed

## Troubleshooting

### Common Issues

1. **Network connectivity problems**
2. **Invalid language codes**
3. **Timeout issues**
4. **Memory management**
5. **Configuration errors**

### Solutions

1. **Check network connectivity**
2. **Verify language codes**
3. **Increase timeout intervals**
4. **Monitor memory usage**
5. **Validate configuration**

## Support

For additional support and documentation:

- [Getting Started Guide](GettingStarted.md)
- [Translation Guide](TranslationGuide.md)
- [API Reference](API.md)
- [Examples](../Examples/TranslationExamples/)
- [GitHub Issues](https://github.com/muhittincamdali/GlobalLingo/issues)

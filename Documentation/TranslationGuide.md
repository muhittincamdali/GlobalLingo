# Translation Guide

## Overview

This comprehensive guide will walk you through setting up and using the GlobalLingo translation framework in your iOS applications. You'll learn how to implement AI-powered translation, machine learning, human review, and translation memory management.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Basic Setup](#basic-setup)
4. [Translation Configuration](#translation-configuration)
5. [Basic Translation](#basic-translation)
6. [Batch Translation](#batch-translation)
7. [Context-Aware Translation](#context-aware-translation)
8. [Translation Quality](#translation-quality)
9. [Translation Memory](#translation-memory)
10. [Human Review](#human-review)
11. [Testing](#testing)
12. [Best Practices](#best-practices)
13. [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have:

- **iOS 15.0+** with iOS 15.0+ SDK
- **Swift 5.9+** programming language
- **Xcode 15.0+** development environment
- **Internet connection** for AI translation services
- **API keys** for translation services (if required)

## Installation

### Swift Package Manager

Add GlobalLingo to your project using Swift Package Manager:

1. In Xcode, go to **File > Add Package Dependencies**
2. Enter the repository URL: `https://github.com/muhittincamdali/GlobalLingo.git`
3. Select the version you want to use
4. Click **Add Package**

## Basic Setup

### 1. Import the Framework

```swift
import GlobalLingo
```

### 2. Initialize the Translation Manager

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    let translationManager = TranslationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure translation
        setupTranslation()
        
        return true
    }
    
    private func setupTranslation() {
        let config = TranslationConfiguration()
        config.enableAITranslation = true
        config.enableMachineLearning = true
        config.enableHumanReview = true
        config.enableTranslationMemory = true
        config.maxBatchSize = 100
        config.timeoutInterval = 30.0
        config.retryCount = 3
        config.qualityThreshold = 0.8
        
        translationManager.configure(config)
    }
}
```

## Translation Configuration

### Configuration Options

```swift
let config = TranslationConfiguration()

// Enable features
config.enableAITranslation = true
config.enableMachineLearning = true
config.enableHumanReview = true
config.enableTranslationMemory = true
config.enableQualityAssurance = true
config.enableCollaborativeTranslation = true
config.enableVersionControl = true
config.enableTranslationAnalytics = true

// Performance settings
config.maxBatchSize = 100
config.timeoutInterval = 30.0
config.retryCount = 3
config.qualityThreshold = 0.8

translationManager.configure(config)
```

## Basic Translation

### Simple Text Translation

```swift
// Translate text from English to Spanish
translationManager.translateText(
    text: "Hello world",
    fromLanguage: "en",
    toLanguage: "es"
) { result in
    switch result {
    case .success(let translation):
        print("Original: \(translation.original)")
        print("Translated: \(translation.translated)")
        print("Confidence: \(translation.confidence)%")
        print("Quality: \(translation.quality)")
    case .failure(let error):
        print("Translation failed: \(error)")
    }
}
```

### SwiftUI Integration

```swift
struct TranslationView: View {
    @StateObject private var translationManager = TranslationManager()
    @State private var originalText = ""
    @State private var translatedText = ""
    @State private var isTranslating = false
    @State private var selectedLanguage = "es"
    
    let languages = [
        ("Spanish", "es"),
        ("French", "fr"),
        ("German", "de"),
        ("Italian", "it"),
        ("Portuguese", "pt")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter text to translate", text: $originalText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("Target Language", selection: $selectedLanguage) {
                ForEach(languages, id: \.1) { language in
                    Text(language.0).tag(language.1)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Button("Translate") {
                translateText()
            }
            .disabled(originalText.isEmpty || isTranslating)
            
            if isTranslating {
                ProgressView("Translating...")
            } else {
                Text(translatedText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
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
        config.timeoutInterval = 30.0
        translationManager.configure(config)
    }
    
    private func translateText() {
        isTranslating = true
        
        translationManager.translateText(
            text: originalText,
            fromLanguage: "en",
            toLanguage: selectedLanguage
        ) { result in
            DispatchQueue.main.async {
                isTranslating = false
                
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
    private let languageSegmentedControl = UISegmentedControl()
    
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
        
        let languages = ["es", "fr", "de", "it"]
        let selectedLanguage = languages[languageSegmentedControl.selectedSegmentIndex]
        
        translateButton.isEnabled = false
        resultLabel.text = "Translating..."
        
        translationManager.translateText(
            text: text,
            fromLanguage: "en",
            toLanguage: selectedLanguage
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.translateButton.isEnabled = true
                
                switch result {
                case .success(let translation):
                    self?.resultLabel.text = translation.translated
                case .failure(let error):
                    self?.resultLabel.text = "Translation failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
```

## Batch Translation

### Multiple Text Translation

```swift
// Translate multiple texts at once
let texts = [
    "Welcome to our app",
    "Thank you for using our service",
    "Please rate your experience",
    "We hope you enjoy using our app"
]

translationManager.batchTranslate(
    texts: texts,
    fromLanguage: "en",
    toLanguage: "fr"
) { result in
    switch result {
    case .success(let translations):
        print("Batch translation completed")
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

## Context-Aware Translation

### Context-Sensitive Translation

```swift
// Translate with context for better accuracy
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

## Translation Quality

### Quality Assessment

```swift
// Improve translation quality with feedback
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
        print("Quality improvement failed: \(error)")
    }
}
```

### Quality Thresholds

```swift
// Set quality thresholds
let qualityThreshold = PerformanceThreshold(
    metric: .translationQuality,
    warningValue: 0.7,
    criticalValue: 0.5,
    action: .alert,
    isEnabled: true
)

translationManager.setThreshold(qualityThreshold, forMetric: .translationQuality)
```

## Translation Memory

### Memory Management

```swift
// Store translations in memory
let translationMemory = TranslationMemory()

translationMemory.store(translation: translation)

// Retrieve from memory
if let cachedTranslation = translationMemory.retrieve(
    original: "Hello world",
    fromLanguage: "en",
    toLanguage: "es"
) {
    print("Found in memory: \(cachedTranslation.translated)")
}
```

## Human Review

### Review Workflow

```swift
// Submit translation for human review
let collaborativeTranslation = CollaborativeTranslation()

collaborativeTranslation.assignTranslation(
    task: translationTask,
    to: translator
)

collaborativeTranslation.reviewTranslation(
    translation: translation,
    by: reviewer
)

collaborativeTranslation.approveTranslation(
    translation: translation,
    by: approver
)
```

## Testing

### Unit Tests

```swift
class TranslationTests: XCTestCase {
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
    }
    
    func testBasicTranslation() {
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
    
    func testBatchTranslation() {
        let expectation = XCTestExpectation(description: "Batch translation completed")
        
        let texts = ["Hello", "World"]
        
        translationManager.batchTranslate(
            texts: texts,
            fromLanguage: "en",
            toLanguage: "fr"
        ) { result in
            switch result {
            case .success(let translations):
                XCTAssertEqual(translations.count, 2)
            case .failure(let error):
                XCTFail("Batch translation failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
```

## Best Practices

### 1. Configuration

- **Always configure the translation manager before use**
- **Set appropriate timeout intervals**
- **Enable only the features you need**
- **Set quality thresholds based on your requirements**

### 2. Error Handling

- **Always handle translation errors gracefully**
- **Provide fallback text for failed translations**
- **Implement retry logic for network failures**
- **Log translation errors for debugging**

### 3. Performance

- **Use batch translation for multiple texts**
- **Cache frequently translated content**
- **Monitor translation quality**
- **Optimize network requests**

### 4. Quality Assurance

- **Review translations for accuracy**
- **Provide feedback to improve quality**
- **Use context-aware translation when possible**
- **Monitor translation confidence scores**

### 5. Security

- **Secure API keys and credentials**
- **Validate input text before translation**
- **Handle sensitive content appropriately**
- **Implement rate limiting**

## Troubleshooting

### Common Issues

#### 1. Network Errors

**Problem**: Translation requests fail due to network issues.

**Solutions**:
- Check internet connectivity
- Verify API endpoints are accessible
- Implement retry logic
- Check firewall settings

#### 2. Timeout Issues

**Problem**: Translation requests timeout.

**Solutions**:
- Increase timeout intervals
- Optimize text length
- Use batch translation for large texts
- Check network performance

#### 3. Quality Issues

**Problem**: Translation quality is poor.

**Solutions**:
- Provide context for better accuracy
- Use human review for important content
- Improve source text quality
- Set appropriate quality thresholds

#### 4. API Limits

**Problem**: Translation requests are rate limited.

**Solutions**:
- Implement rate limiting
- Use translation memory
- Cache frequently used translations
- Monitor API usage

### Debugging Tips

1. **Enable debug logging**:
```swift
let config = TranslationConfiguration()
config.enableDebugLogging = true
```

2. **Check translation quality**:
```swift
if translation.confidence < 0.8 {
    print("Low confidence translation: \(translation.confidence)")
}
```

3. **Monitor performance**:
```swift
let startTime = Date()
translationManager.translateText(...) { result in
    let duration = Date().timeIntervalSince(startTime)
    print("Translation took: \(duration) seconds")
}
```

## Support

For additional support and documentation:

- [API Reference](TranslationAPI.md)
- [Examples](../Examples/TranslationExamples/)
- [GitHub Issues](https://github.com/muhittincamdali/GlobalLingo/issues)
- [Community Discussions](https://github.com/muhittincamdali/GlobalLingo/discussions)

## Next Steps

Now that you have a solid understanding of translation with GlobalLingo, you can:

1. **Explore advanced features** like translation memory and human review
2. **Implement quality assurance** workflows
3. **Add performance monitoring** to track translation performance
4. **Contribute to the project** by reporting issues or submitting pull requests
5. **Share your experience** with the community

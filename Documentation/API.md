# 📚 GlobalLingo API Reference

Complete API documentation for GlobalLingo framework.

## Core Classes

### GlobalLingoManager

The main entry point for GlobalLingo framework.

```swift
class GlobalLingoManager {
    func start(completion: @escaping (Result<Void, Error>) -> Void)
    func translate(text: String, to: String, from: String, completion: @escaping (Result<Translation, Error>) -> Void)
    func recognizeVoice(audioData: Data, language: String, completion: @escaping (Result<VoiceRecognition, Error>) -> Void)
}
```

### TranslationEngine

Advanced translation capabilities with AI support.

```swift
class TranslationEngine {
    func translateWithAI(text: String, from: String, to: String, context: TranslationContext?, options: AITranslationOptions, completion: @escaping (Result<AITranslation, Error>) -> Void)
    func batchTranslate(texts: [String], from: String, to: String, completion: @escaping (Result<[Translation], Error>) -> Void)
}
```

## Configuration

### GlobalLingoConfiguration

```swift
struct GlobalLingoConfiguration {
    var debugMode: Bool
    var logLevel: LogLevel
    var enablePerformanceMonitoring: Bool
    var enableAnalytics: Bool
}
```

For complete API reference, see the inline documentation in the source code.
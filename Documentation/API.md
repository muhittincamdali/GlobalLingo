# 📚 API Reference

Complete API documentation for GlobalLingo translation framework.

## 📋 Table of Contents

- [TranslationEngine](#translationengine)
- [VoiceRecognition](#voicerecognition)
- [LanguageManager](#languagemanager)
- [OfflineService](#offlineservice)
- [PerformanceMonitor](#performancemonitor)
- [Error Handling](#error-handling)

## 🔧 TranslationEngine

The main translation engine for text and voice translation.

### Initialization

```swift
let translationEngine = TranslationEngine()
```

### Configuration

```swift
translationEngine.configure(
    defaultSourceLanguage: .english,
    defaultTargetLanguage: .spanish,
    enableOfflineMode: true,
    enableCaching: true,
    cacheSize: 1000
)
```

### Text Translation

#### Single Translation
```swift
func translate(
    text: String,
    from: Language,
    to: Language
) async throws -> String
```

**Parameters:**
- `text`: The text to translate
- `from`: Source language
- `to`: Target language

**Returns:** Translated text

**Example:**
```swift
let result = try await translationEngine.translate(
    text: "Hello, how are you?",
    from: .english,
    to: .spanish
)
// Returns: "Hola, ¿cómo estás?"
```

#### Batch Translation
```swift
func translateBatch(
    texts: [String],
    from: Language,
    to: Language
) async throws -> [String]
```

**Parameters:**
- `texts`: Array of texts to translate
- `from`: Source language
- `to`: Target language

**Returns:** Array of translated texts

**Example:**
```swift
let texts = ["Hello", "Goodbye", "Thank you"]
let results = try await translationEngine.translateBatch(
    texts: texts,
    from: .english,
    to: .german
)
// Returns: ["Hallo", "Auf Wiedersehen", "Danke"]
```

### Voice Translation

#### Voice to Text
```swift
func translateVoice(
    audioData: Data,
    from: Language,
    to: Language
) async throws -> VoiceTranslationResult
```

**Parameters:**
- `audioData`: Audio data to translate
- `from`: Source language
- `to`: Target language

**Returns:** VoiceTranslationResult containing text and audio

**Example:**
```swift
let result = try await translationEngine.translateVoice(
    audioData: voiceData,
    from: .english,
    to: .french
)
```

### Language Detection

```swift
func detectLanguage(text: String) async throws -> Language
```

**Parameters:**
- `text`: Text to detect language for

**Returns:** Detected language

**Example:**
```swift
let language = try await translationEngine.detectLanguage(
    text: "Bonjour, comment allez-vous?"
)
// Returns: .french
```

### Offline Translation

#### Check Availability
```swift
func isOfflineAvailable(from: Language, to: Language) -> Bool
```

**Parameters:**
- `from`: Source language
- `to`: Target language

**Returns:** Boolean indicating offline availability

#### Offline Translation
```swift
func translateOffline(
    text: String,
    from: Language,
    to: Language
) async throws -> String
```

**Parameters:**
- `text`: Text to translate
- `from`: Source language
- `to`: Target language

**Returns:** Translated text

## 🎤 VoiceRecognition

Voice recognition and speech-to-text functionality.

### Initialization

```swift
let voiceRecognition = VoiceRecognition()
```

### Configuration

```swift
voiceRecognition.configure(
    language: .english,
    enableNoiseCancellation: true,
    enableAccentRecognition: true
)
```

### Speech Recognition

#### Start Recording
```swift
func startRecording() async throws
```

**Example:**
```swift
try await voiceRecognition.startRecording()
```

#### Stop Recording
```swift
func stopRecording() async throws
```

**Example:**
```swift
try await voiceRecognition.stopRecording()
```

#### Get Recognized Text
```swift
func getRecognizedText() async throws -> String
```

**Returns:** Recognized text from speech

**Example:**
```swift
let text = try await voiceRecognition.getRecognizedText()
```

#### Recognize Speech from Audio
```swift
func recognizeSpeech(audioData: Data) async throws -> String
```

**Parameters:**
- `audioData`: Audio data to recognize

**Returns:** Recognized text

**Example:**
```swift
let text = try await voiceRecognition.recognizeSpeech(
    audioData: voiceData
)
```

### Voice Quality

#### Set Audio Quality
```swift
func setAudioQuality(_ quality: AudioQuality)
```

**Parameters:**
- `quality`: Audio quality setting

**Example:**
```swift
voiceRecognition.setAudioQuality(.high)
```

#### Get Audio Quality
```swift
func getAudioQuality() -> AudioQuality
```

**Returns:** Current audio quality setting

## 🌍 LanguageManager

Language management and support.

### Get Supported Languages

```swift
func getSupportedLanguages() -> [Language]
```

**Returns:** Array of supported languages

**Example:**
```swift
let languages = languageManager.getSupportedLanguages()
```

### Check Language Support

```swift
func isLanguageSupported(_ language: Language) -> Bool
```

**Parameters:**
- `language`: Language to check

**Returns:** Boolean indicating support

**Example:**
```swift
let isSupported = languageManager.isLanguageSupported(.japanese)
```

### Get Language Info

```swift
func getLanguageInfo(_ language: Language) -> LanguageInfo
```

**Parameters:**
- `language`: Language to get info for

**Returns:** LanguageInfo containing details

**Example:**
```swift
let info = languageManager.getLanguageInfo(.spanish)
print(info.name) // "Spanish"
print(info.nativeName) // "Español"
```

## 📱 OfflineService

Offline translation capabilities.

### Check Offline Availability

```swift
func isOfflineAvailable(from: Language, to: Language) -> Bool
```

**Parameters:**
- `from`: Source language
- `to`: Target language

**Returns:** Boolean indicating offline availability

### Download Language Pack

```swift
func downloadLanguagePack(
    for language: Language
) async throws -> Bool
```

**Parameters:**
- `language`: Language to download

**Returns:** Boolean indicating success

**Example:**
```swift
let success = try await offlineService.downloadLanguagePack(
    for: .spanish
)
```

### Get Downloaded Languages

```swift
func getDownloadedLanguages() -> [Language]
```

**Returns:** Array of downloaded languages

**Example:**
```swift
let downloaded = offlineService.getDownloadedLanguages()
```

### Remove Language Pack

```swift
func removeLanguagePack(for language: Language) async throws
```

**Parameters:**
- `language`: Language to remove

**Example:**
```swift
try await offlineService.removeLanguagePack(for: .spanish)
```

## ⚡ PerformanceMonitor

Performance monitoring and metrics.

### Get Performance Metrics

```swift
func getPerformanceMetrics() -> PerformanceMetrics
```

**Returns:** PerformanceMetrics containing various metrics

**Example:**
```swift
let metrics = performanceMonitor.getPerformanceMetrics()
print("Average response time: \(metrics.averageResponseTime)ms")
print("Memory usage: \(metrics.memoryUsage)MB")
```

### Performance Metrics Structure

```swift
struct PerformanceMetrics {
    let averageResponseTime: TimeInterval
    let memoryUsage: Int64
    let cpuUsage: Float
    let gpuUsage: Float?
    let cacheHitRate: Float
    let networkRequests: Int
    let offlineRequests: Int
}
```

### Enable Performance Monitoring

```swift
func enablePerformanceMonitoring()
```

**Example:**
```swift
performanceMonitor.enablePerformanceMonitoring()
```

### Disable Performance Monitoring

```swift
func disablePerformanceMonitoring()
```

**Example:**
```swift
performanceMonitor.disablePerformanceMonitoring()
```

## ❌ Error Handling

### TranslationError

```swift
enum TranslationError: Error {
    case networkError
    case languageNotSupported
    case invalidInput
    case translationFailed
    case offlineNotAvailable
    case voiceRecognitionFailed
    case audioProcessingError
}
```

### Error Handling Example

```swift
do {
    let result = try await translationEngine.translate(
        text: "Hello",
        from: .english,
        to: .spanish
    )
} catch TranslationError.networkError {
    // Handle network error
    print("Network connection failed")
} catch TranslationError.languageNotSupported {
    // Handle unsupported language
    print("Language not supported")
} catch TranslationError.offlineNotAvailable {
    // Handle offline not available
    print("Offline translation not available")
} catch {
    // Handle other errors
    print("Translation failed: \(error)")
}
```

### VoiceRecognitionError

```swift
enum VoiceRecognitionError: Error {
    case audioCaptureFailed
    case recognitionFailed
    case languageNotSupported
    case audioQualityTooLow
    case microphoneNotAvailable
}
```

### Error Handling for Voice

```swift
do {
    let text = try await voiceRecognition.recognizeSpeech(
        audioData: voiceData
    )
} catch VoiceRecognitionError.audioCaptureFailed {
    // Handle audio capture error
    print("Failed to capture audio")
} catch VoiceRecognitionError.recognitionFailed {
    // Handle recognition error
    print("Speech recognition failed")
} catch {
    // Handle other errors
    print("Voice recognition failed: \(error)")
}
```

## 📊 Data Structures

### Language Enum

```swift
enum Language: String, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case russian = "ru"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    // ... more languages
}
```

### LanguageInfo Structure

```swift
struct LanguageInfo {
    let code: String
    let name: String
    let nativeName: String
    let isOfflineAvailable: Bool
    let isVoiceSupported: Bool
}
```

### VoiceTranslationResult Structure

```swift
struct VoiceTranslationResult {
    let originalText: String
    let translatedText: String
    let audioData: Data?
    let confidence: Float
    let language: Language
}
```

---

**For more information, visit our [GitHub repository](https://github.com/muhittincamdali/GlobalLingo).** 
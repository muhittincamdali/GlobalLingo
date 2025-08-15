# 📱 iOS Integration Guide

Complete guide for integrating GlobalLingo into your iOS applications.

## Prerequisites

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/GlobalLingo.git", from: "2.0.0")
]
```

### Import Framework

```swift
import GlobalLingo
```

## Basic Integration

### 1. Initialize GlobalLingo

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    let globalLingo = GlobalLingoManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        globalLingo.start { result in
            switch result {
            case .success:
                print("✅ GlobalLingo initialized successfully")
            case .failure(let error):
                print("❌ Failed to initialize: \(error)")
            }
        }
        
        return true
    }
}
```

### 2. SwiftUI Integration

```swift
import SwiftUI
import GlobalLingo

struct ContentView: View {
    @StateObject private var globalLingo = GlobalLingoManager()
    @State private var translatedText = ""
    
    var body: some View {
        VStack {
            Text("Welcome to GlobalLingo")
                .font(.largeTitle)
                .padding()
            
            Button("Translate to Spanish") {
                translateWelcomeMessage()
            }
            .padding()
            
            Text(translatedText)
                .padding()
        }
        .onAppear {
            globalLingo.start { _ in }
        }
    }
    
    private func translateWelcomeMessage() {
        globalLingo.translate(
            text: "Welcome to GlobalLingo",
            to: "es",
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self.translatedText = translation.translatedText
                case .failure(let error):
                    self.translatedText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
```

### 3. UIKit Integration

```swift
import UIKit
import GlobalLingo

class ViewController: UIViewController {
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var translatedLabel: UILabel!
    @IBOutlet weak var translateButton: UIButton!
    
    private let globalLingo = GlobalLingoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlobalLingo()
    }
    
    private func setupGlobalLingo() {
        globalLingo.start { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.translateButton.isEnabled = true
                case .failure(let error):
                    print("Failed to start GlobalLingo: \(error)")
                }
            }
        }
    }
    
    @IBAction func translateButtonTapped(_ sender: UIButton) {
        let sourceText = sourceLabel.text ?? ""
        
        globalLingo.translate(
            text: sourceText,
            to: "fr",
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self.translatedLabel.text = translation.translatedText
                case .failure(let error):
                    self.translatedLabel.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
```

## Advanced Features

### Voice Recognition

```swift
import AVFoundation
import GlobalLingo

class VoiceViewController: UIViewController {
    private let globalLingo = GlobalLingoManager()
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    
    private func startVoiceRecognition() {
        // Record audio data
        let audioData = recordAudio()
        
        globalLingo.recognizeVoice(
            audioData: audioData,
            language: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recognition):
                    print("Recognized: \(recognition.recognizedText)")
                case .failure(let error):
                    print("Recognition failed: \(error)")
                }
            }
        }
    }
    
    private func recordAudio() -> Data {
        // Implementation for audio recording
        return Data()
    }
}
```

### Cultural Adaptation

```swift
import GlobalLingo

class CulturalAdaptationExample {
    private let globalLingo = GlobalLingoManager()
    
    func adaptForCulture() {
        let culturalContent = CulturalContent(
            text: "Hello, how are you?",
            sourceCulture: "en-US",
            targetCulture: "ja-JP"
        )
        
        globalLingo.adaptCulture(
            content: culturalContent,
            to: "ja-JP"
        ) { result in
            switch result {
            case .success(let adaptation):
                print("Adapted content: \(adaptation.adaptedText)")
            case .failure(let error):
                print("Cultural adaptation failed: \(error)")
            }
        }
    }
}
```

## Configuration

### Custom Configuration

```swift
let config = GlobalLingoConfiguration()
config.debugMode = true
config.enablePerformanceMonitoring = true
config.enableAnalytics = false

// Translation specific settings
config.translationConfig.enableContextAwareTranslation = true
config.translationConfig.enableDomainSpecificTranslation = true

// Security settings
config.securityConfig.enableEncryption = true
config.securityConfig.enableBiometricAuth = true

globalLingo.configure(config)
```

## Best Practices

1. **Initialize Early**: Start GlobalLingo in AppDelegate
2. **Handle Errors**: Always implement proper error handling
3. **Performance**: Use background queues for heavy operations
4. **Memory**: Properly manage GlobalLingo instances
5. **Security**: Enable encryption for sensitive data
6. **Testing**: Test translation functionality thoroughly

## Troubleshooting

### Common Issues

**Issue**: Translation not working
**Solution**: Check internet connectivity and API keys

**Issue**: Voice recognition failing
**Solution**: Verify microphone permissions

**Issue**: Performance issues
**Solution**: Enable performance monitoring and optimize

For more examples, see [Basic Examples](../Examples/BasicExamples.md).
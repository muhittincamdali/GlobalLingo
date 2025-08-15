# =ñ Basic Examples

Simple code examples to get you started with GlobalLingo.

## Basic Translation

```swift
import GlobalLingo

class BasicTranslationExample {
    let globalLingo = GlobalLingoManager()
    
    func translateText() {
        globalLingo.start { result in
            switch result {
            case .success:
                self.performTranslation()
            case .failure(let error):
                print("Failed to start: \(error)")
            }
        }
    }
    
    private func performTranslation() {
        globalLingo.translate(
            text: "Hello, world!",
            to: "es",
            from: "en"
        ) { result in
            switch result {
            case .success(let translation):
                print("Translated: \(translation.translatedText)")
            case .failure(let error):
                print("Translation failed: \(error)")
            }
        }
    }
}
```

## Voice Recognition

```swift
import GlobalLingo
import AVFoundation

class VoiceRecognitionExample {
    let globalLingo = GlobalLingoManager()
    
    func recognizeVoice(audioData: Data) {
        globalLingo.recognizeVoice(
            audioData: audioData,
            language: "en"
        ) { result in
            switch result {
            case .success(let recognition):
                print("Recognized: \(recognition.recognizedText)")
            case .failure(let error):
                print("Recognition failed: \(error)")
            }
        }
    }
}
```

## SwiftUI Integration

```swift
import SwiftUI
import GlobalLingo

struct TranslationView: View {
    @StateObject private var globalLingo = GlobalLingoManager()
    @State private var inputText = ""
    @State private var translatedText = ""
    
    var body: some View {
        VStack {
            TextField("Enter text to translate", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Translate to Spanish") {
                translateText()
            }
            
            Text(translatedText)
                .padding()
        }
        .padding()
        .onAppear {
            globalLingo.start { _ in }
        }
    }
    
    private func translateText() {
        globalLingo.translate(
            text: inputText,
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

## Configuration Example

```swift
import GlobalLingo

class ConfigurationExample {
    func setupGlobalLingo() {
        let config = GlobalLingoConfiguration()
        config.debugMode = true
        config.enablePerformanceMonitoring = true
        config.enableAnalytics = false
        
        let globalLingo = GlobalLingoManager()
        globalLingo.configure(config)
        
        globalLingo.start { result in
            switch result {
            case .success:
                print("GlobalLingo configured and started")
            case .failure(let error):
                print("Failed to start: \(error)")
            }
        }
    }
}
```

For more advanced examples, see [Advanced Examples](AdvancedExamples.md).
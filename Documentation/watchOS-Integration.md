# ⌚ watchOS Integration Guide

Complete guide for integrating GlobalLingo into your watchOS applications.

## Prerequisites

- watchOS 8.0+
- Xcode 15.0+
- Swift 5.9+
- Paired iPhone with iOS 15.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/GlobalLingo.git", from: "2.0.0")
]
```

## WatchKit Integration

### 1. Basic Setup

```swift
import WatchKit
import Foundation
import GlobalLingo

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var sourceLabel: WKInterfaceLabel!
    @IBOutlet weak var translatedLabel: WKInterfaceLabel!
    @IBOutlet weak var translateButton: WKInterfaceButton!
    
    private let globalLingo = GlobalLingoManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupGlobalLingo()
    }
    
    private func setupGlobalLingo() {
        globalLingo.start { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.translateButton.setEnabled(true)
                case .failure(let error):
                    print("Failed to start GlobalLingo: \(error)")
                }
            }
        }
    }
    
    @IBAction func translateButtonTapped() {
        let sourceText = "Hello from Apple Watch"
        
        globalLingo.translate(
            text: sourceText,
            to: "es",
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self.translatedLabel.setText(translation.translatedText)
                case .failure(let error):
                    self.translatedLabel.setText("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
```

### 2. SwiftUI for watchOS

```swift
import SwiftUI
import GlobalLingo

struct ContentView: View {
    @StateObject private var globalLingo = GlobalLingoManager()
    @State private var translatedText = "Tap to translate"
    @State private var isLoading = false
    
    let phrases = [
        "Good morning",
        "How are you?",
        "Thank you",
        "See you later"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("GlobalLingo")
                    .font(.headline)
                    .padding(.bottom)
                
                Text(translatedText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Button("Translate Random") {
                        translateRandomPhrase()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Translate")
        }
        .onAppear {
            globalLingo.start { _ in }
        }
    }
    
    private func translateRandomPhrase() {
        isLoading = true
        let randomPhrase = phrases.randomElement() ?? "Hello"
        
        globalLingo.translate(
            text: randomPhrase,
            to: "fr",
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
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

## Voice Recognition for watchOS

### Dictation Integration

```swift
import WatchKit
import GlobalLingo

class VoiceTranslationController: WKInterfaceController {
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var resultLabel: WKInterfaceLabel!
    @IBOutlet weak var dictateButton: WKInterfaceButton!
    
    private let globalLingo = GlobalLingoManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        globalLingo.start { _ in }
    }
    
    @IBAction func dictateButtonTapped() {
        presentTextInputController(
            withSuggestions: nil,
            allowedInputMode: .allowEmoji
        ) { [weak self] results in
            guard let self = self,
                  let text = results?.first as? String else { return }
            
            self.translateDictatedText(text)
        }
    }
    
    private func translateDictatedText(_ text: String) {
        statusLabel.setText("Translating...")
        
        globalLingo.translate(
            text: text,
            to: "es",
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self.statusLabel.setText("Translated:")
                    self.resultLabel.setText(translation.translatedText)
                case .failure(let error):
                    self.statusLabel.setText("Error:")
                    self.resultLabel.setText(error.localizedDescription)
                }
            }
        }
    }
}
```

## Complications Support

### Translation Complication

```swift
import ClockKit
import GlobalLingo

class ComplicationController: NSObject, CLKComplicationDataSource {
    private let globalLingo = GlobalLingoManager()
    
    override init() {
        super.init()
        globalLingo.start { _ in }
    }
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "translation_complication",
                displayName: "Quick Translate",
                supportedFamilies: [.modularSmall, .utilitarianSmall, .circularSmall]
            )
        ]
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Handle shared complications if needed
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date().addingTimeInterval(24 * 60 * 60)) // 24 hours
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let template = createComplicationTemplate(for: complication.family)
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }
    
    private func createComplicationTemplate(for family: CLKComplicationFamily) -> CLKComplicationTemplate {
        switch family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "🌍")
            return template
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "Translate")
            return template
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "🌍")
            return template
        default:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "🌍")
            return template
        }
    }
}
```

## Watch Connectivity

### Communication with iOS App

```swift
import WatchConnectivity
import GlobalLingo

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    private let globalLingo = GlobalLingoManager()
    
    override init() {
        super.init()
        setupWatchConnectivity()
        globalLingo.start { _ in }
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func requestTranslationFromPhone(_ text: String, to language: String) {
        guard WCSession.default.isReachable else {
            // Fallback to local translation
            performLocalTranslation(text, to: language)
            return
        }
        
        let message = [
            "action": "translate",
            "text": text,
            "targetLanguage": language
        ]
        
        WCSession.default.sendMessage(message) { response in
            if let translatedText = response["translatedText"] as? String {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("TranslationReceived"),
                        object: translatedText
                    )
                }
            }
        } errorHandler: { error in
            print("Failed to send message to phone: \(error)")
            self.performLocalTranslation(text, to: language)
        }
    }
    
    private func performLocalTranslation(_ text: String, to language: String) {
        globalLingo.translate(
            text: text,
            to: language,
            from: "en"
        ) { result in
            switch result {
            case .success(let translation):
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("TranslationReceived"),
                        object: translation.translatedText
                    )
                }
            case .failure(let error):
                print("Local translation failed: \(error)")
            }
        }
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activation completed with state: \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle messages from iOS app
    }
}
```

## Configuration for watchOS

### Watch-Optimized Settings

```swift
let config = GlobalLingoConfiguration()
config.debugMode = false
config.enablePerformanceMonitoring = true

// watchOS specific optimizations
config.performanceConfig.enableWatchOptimization = true
config.performanceConfig.cacheSizeLimit = 10 * 1024 * 1024 // 10MB for watch
config.performanceConfig.enableBatteryOptimization = true

// Limit features for watch
config.translationConfig.enableOfflineTranslation = true
config.translationConfig.maxCachedTranslations = 100

globalLingo.configure(config)
```

## Best Practices for watchOS

1. **Battery Life**: Minimize background processing
2. **Quick Interactions**: Design for brief interactions
3. **Offline Support**: Cache common translations
4. **Complications**: Provide quick access via complications
5. **Voice Input**: Leverage dictation for text input
6. **iPhone Connectivity**: Use iPhone for heavy processing
7. **Small Screen**: Design for small display

## Example: Travel Companion App

```swift
import SwiftUI
import GlobalLingo

struct TravelCompanionView: View {
    @StateObject private var globalLingo = GlobalLingoManager()
    @State private var selectedPhrase = 0
    @State private var translatedPhrase = ""
    @State private var targetLanguage = "es"
    
    let travelPhrases = [
        "Where is the bathroom?",
        "How much does this cost?",
        "Can you help me?",
        "I don't speak the language",
        "Thank you very much"
    ]
    
    let languages = ["es": "Spanish", "fr": "French", "de": "German"]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Language", selection: $targetLanguage) {
                    ForEach(Array(languages.keys), id: \.self) { key in
                        Text(languages[key]!).tag(key)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 80)
                
                Text(travelPhrases[selectedPhrase])
                    .font(.caption)
                    .padding()
                
                Text(translatedPhrase)
                    .font(.body)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack {
                    Button("Previous") {
                        if selectedPhrase > 0 {
                            selectedPhrase -= 1
                            translateCurrentPhrase()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Next") {
                        if selectedPhrase < travelPhrases.count - 1 {
                            selectedPhrase += 1
                            translateCurrentPhrase()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Travel Helper")
        }
        .onAppear {
            globalLingo.start { _ in
                translateCurrentPhrase()
            }
        }
        .onChange(of: targetLanguage) { _ in
            translateCurrentPhrase()
        }
    }
    
    private func translateCurrentPhrase() {
        globalLingo.translate(
            text: travelPhrases[selectedPhrase],
            to: targetLanguage,
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self.translatedPhrase = translation.translatedText
                case .failure(let error):
                    self.translatedPhrase = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
```

For more examples, see [Basic Examples](../Examples/BasicExamples.md).
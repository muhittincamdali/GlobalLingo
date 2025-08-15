# 💻 macOS Integration Guide

Complete guide for integrating GlobalLingo into your macOS applications.

## Prerequisites

- macOS 12.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/GlobalLingo.git", from: "2.0.0")
]
```

## AppKit Integration

### 1. Initialize in AppDelegate

```swift
import Cocoa
import GlobalLingo

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let globalLingo = GlobalLingoManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        globalLingo.start { result in
            switch result {
            case .success:
                print("✅ GlobalLingo started for macOS")
            case .failure(let error):
                print("❌ Failed to start: \(error)")
            }
        }
    }
}
```

### 2. SwiftUI for macOS

```swift
import SwiftUI
import GlobalLingo

struct ContentView: View {
    @StateObject private var globalLingo = GlobalLingoManager()
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var selectedLanguage = "es"
    
    let languages = ["es": "Spanish", "fr": "French", "de": "German", "it": "Italian"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("GlobalLingo for macOS")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            GroupBox("Translation") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter text to translate:")
                        .font(.headline)
                    
                    TextEditor(text: $inputText)
                        .frame(height: 100)
                        .border(Color.gray, width: 1)
                    
                    HStack {
                        Text("Translate to:")
                        Picker("Language", selection: $selectedLanguage) {
                            ForEach(languages.sorted(by: { $0.0 < $1.0 }), id: \.key) { key, value in
                                Text(value).tag(key)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Spacer()
                        
                        Button("Translate") {
                            translateText()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(inputText.isEmpty)
                    }
                }
                .padding()
            }
            
            GroupBox("Result") {
                ScrollView {
                    Text(translatedText.isEmpty ? "Translation will appear here..." : translatedText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(height: 150)
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            globalLingo.start { _ in }
        }
    }
    
    private func translateText() {
        globalLingo.translate(
            text: inputText,
            to: selectedLanguage,
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

### 3. NSViewController Integration

```swift
import Cocoa
import GlobalLingo

class TranslationViewController: NSViewController {
    @IBOutlet weak var sourceTextView: NSTextView!
    @IBOutlet weak var translatedTextView: NSTextView!
    @IBOutlet weak var languagePopUpButton: NSPopUpButton!
    @IBOutlet weak var translateButton: NSButton!
    
    private let globalLingo = GlobalLingoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlobalLingo()
        setupLanguageOptions()
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
    
    private func setupLanguageOptions() {
        languagePopUpButton.removeAllItems()
        languagePopUpButton.addItems(withTitles: ["Spanish", "French", "German", "Italian", "Portuguese"])
    }
    
    @IBAction func translateButtonClicked(_ sender: NSButton) {
        guard let sourceText = sourceTextView.textStorage?.string,
              !sourceText.isEmpty else { return }
        
        let languageCodes = ["es", "fr", "de", "it", "pt"]
        let selectedIndex = languagePopUpButton.indexOfSelectedItem
        let targetLanguage = languageCodes[selectedIndex]
        
        globalLingo.translate(
            text: sourceText,
            to: targetLanguage,
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self.translatedTextView.textStorage?.setAttributedString(
                        NSAttributedString(string: translation.translatedText)
                    )
                case .failure(let error):
                    self.translatedTextView.textStorage?.setAttributedString(
                        NSAttributedString(string: "Error: \(error.localizedDescription)")
                    )
                }
            }
        }
    }
}
```

## Desktop-Specific Features

### Menu Bar Integration

```swift
import Cocoa
import GlobalLingo

class MenuBarManager: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let globalLingo = GlobalLingoManager()
    
    override init() {
        super.init()
        setupMenuBar()
        setupGlobalLingo()
    }
    
    private func setupMenuBar() {
        statusItem.button?.title = "🌍"
        statusItem.button?.action = #selector(menuBarButtonClicked)
        statusItem.button?.target = self
    }
    
    private func setupGlobalLingo() {
        globalLingo.start { _ in }
    }
    
    @objc private func menuBarButtonClicked() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Quick Translate", action: #selector(quickTranslate), keyEquivalent: "t"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    @objc private func quickTranslate() {
        // Implement quick translation from clipboard
    }
    
    @objc private func showPreferences() {
        // Show preferences window
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
```

### Drag & Drop Support

```swift
import Cocoa
import GlobalLingo

class DragDropView: NSView {
    private let globalLingo = GlobalLingoManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDragDrop()
        globalLingo.start { _ in }
    }
    
    private func setupDragDrop() {
        registerForDraggedTypes([.string, .fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        
        if let string = pasteboard.string(forType: .string) {
            translateDroppedText(string)
            return true
        }
        
        return false
    }
    
    private func translateDroppedText(_ text: String) {
        globalLingo.translate(
            text: text,
            to: "es",
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    print("Translated dropped text: \(translation.translatedText)")
                case .failure(let error):
                    print("Translation failed: \(error)")
                }
            }
        }
    }
}
```

## Configuration for macOS

### Desktop-Optimized Settings

```swift
let config = GlobalLingoConfiguration()
config.enablePerformanceMonitoring = true
config.enableAnalytics = true

// macOS specific optimizations
config.performanceConfig.enableDesktopOptimization = true
config.performanceConfig.cacheSizeLimit = 500 * 1024 * 1024 // 500MB for desktop

// Security settings for desktop
config.securityConfig.enableFileSystemAccess = true
config.securityConfig.enableNetworkAccess = true

globalLingo.configure(config)
```

## Best Practices for macOS

1. **Menu Bar**: Consider menu bar integration for quick access
2. **Performance**: Utilize more generous memory limits on desktop
3. **File System**: Implement drag & drop for files
4. **Keyboard Shortcuts**: Add global keyboard shortcuts
5. **Multi-Window**: Support multiple translation windows
6. **Preferences**: Provide comprehensive preference panels

## Example Applications

### Document Translator

```swift
import Cocoa
import GlobalLingo

class DocumentTranslator {
    private let globalLingo = GlobalLingoManager()
    
    func translateDocument(at url: URL, to language: String) {
        do {
            let content = try String(contentsOf: url)
            
            globalLingo.translate(
                text: content,
                to: language,
                from: "en"
            ) { result in
                switch result {
                case .success(let translation):
                    self.saveTranslatedDocument(translation.translatedText, originalURL: url, language: language)
                case .failure(let error):
                    print("Document translation failed: \(error)")
                }
            }
        } catch {
            print("Failed to read document: \(error)")
        }
    }
    
    private func saveTranslatedDocument(_ translatedText: String, originalURL: URL, language: String) {
        let fileName = originalURL.deletingPathExtension().lastPathComponent
        let newFileName = "\(fileName)_\(language).txt"
        let newURL = originalURL.deletingLastPathComponent().appendingPathComponent(newFileName)
        
        do {
            try translatedText.write(to: newURL, atomically: true, encoding: .utf8)
            print("Translated document saved to: \(newURL)")
        } catch {
            print("Failed to save translated document: \(error)")
        }
    }
}
```

For more advanced examples, see [Advanced Examples](../Examples/AdvancedExamples.md).
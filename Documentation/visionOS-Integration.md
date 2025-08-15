# >} visionOS Integration Guide

Complete guide for integrating GlobalLingo into your visionOS applications.

## Prerequisites

- visionOS 1.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/GlobalLingo.git", from: "2.0.0")
]
```

## RealityKit Integration

```swift
import SwiftUI
import RealityKit
import GlobalLingo

struct ARTranslationView: View {
    @StateObject private var globalLingo = GlobalLingoManager()
    @State private var translatedText = ""
    
    var body: some View {
        ZStack {
            RealityView { content in
                // AR content
            }
            
            VStack {
                Text(translatedText)
                    .font(.title)
                    .padding()
                
                Button("Translate AR Text") {
                    translateARContent()
                }
            }
        }
        .onAppear {
            globalLingo.start { _ in }
        }
    }
    
    private func translateARContent() {
        globalLingo.translate(
            text: "Welcome to AR",
            to: "es",
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self.translatedText = translation.translatedText
                case .failure(let error):
                    print("AR translation failed: \(error)")
                }
            }
        }
    }
}
```

For more examples, see [Basic Examples](../Examples/BasicExamples.md).
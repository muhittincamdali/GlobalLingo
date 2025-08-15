# 🚀 Getting Started with GlobalLingo

Welcome to GlobalLingo, the most comprehensive iOS localization and translation framework!

## Prerequisites

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- macOS 12.0+

## Installation

### Swift Package Manager (Recommended)

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/GlobalLingo.git", from: "2.0.0")
]
```

### CocoaPods
```ruby
pod 'GlobalLingo', '~> 2.0.0'
```

## Basic Setup

```swift
import GlobalLingo

// Initialize GlobalLingo
let globalLingo = GlobalLingoManager()

// Start the framework
globalLingo.start { result in
    switch result {
    case .success:
        print("✅ GlobalLingo started successfully")
    case .failure(let error):
        print("❌ Failed to start: \(error)")
    }
}
```

## First Translation

```swift
// Translate text
globalLingo.translate(
    text: "Hello, world!",
    to: "es",
    from: "en"
) { result in
    switch result {
    case .success(let translation):
        print("✅ Translation: \(translation.translatedText)")
    case .failure(let error):
        print("❌ Translation failed: \(error)")
    }
}
```

## Next Steps

- Check out our [Examples](../Examples/) folder
- Read the [API Documentation](API.md)
- Explore [Architecture Guide](Architecture.md)
- Learn about [Performance Optimization](Performance.md)

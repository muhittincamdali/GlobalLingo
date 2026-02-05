<h1 align="center">GlobalLingo</h1>

<p align="center">
  <strong>🌍 Powerful localization and internationalization framework for iOS</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml">
    <img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="CI Status"/>
  </a>
  <img src="https://img.shields.io/badge/Swift-6.0-FA7343?style=flat-square&logo=swift&logoColor=white" alt="Swift 6.0"/>
  <img src="https://img.shields.io/badge/iOS-17.0+-000000?style=flat-square&logo=apple&logoColor=white" alt="iOS 17.0+"/>
  <img src="https://img.shields.io/badge/SPM-Compatible-FA7343?style=flat-square&logo=swift&logoColor=white" alt="SPM"/>
  <a href="https://cocoapods.org/pods/GlobalLingo">
    <img src="https://img.shields.io/badge/CocoaPods-Compatible-EE3322?style=flat-square&logo=cocoapods&logoColor=white" alt="CocoaPods"/>
  </a>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"/>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#documentation">Documentation</a>
</p>

---

## 📋 Table of Contents

- [Why GlobalLingo?](#why-globallingo)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)
- [Star History](#-star-history)

---

## Why GlobalLingo?

Localizing iOS apps is tedious. Managing `.strings` files, handling plurals, formatting dates/numbers for different locales—it's a mess. **GlobalLingo** simplifies everything with a modern, type-safe API.

```swift
// Before: Scattered, error-prone
let text = NSLocalizedString("welcome_message", comment: "")
let formatted = String(format: NSLocalizedString("items_count", comment: ""), count)

// After: Clean, type-safe
let text = L10n.welcomeMessage
let formatted = L10n.itemsCount(count)
```

## Features

| Feature | Description |
|---------|-------------|
| 🔤 **Type-Safe Strings** | Generated Swift code, no typos |
| 📊 **Smart Plurals** | ICU MessageFormat support |
| 🗓️ **Date/Time Formatting** | Locale-aware formatting |
| 💰 **Currency & Numbers** | Proper decimal/currency formatting |
| 🔄 **Runtime Language Switch** | Change language without restart |
| 📦 **Remote Strings** | Update translations OTA |
| 🤖 **Auto Translation** | ML-powered translation suggestions |
| 📱 **SwiftUI Native** | @Environment integration |

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/GlobalLingo.git", from: "1.0.0")
]
```

## Quick Start

### 1. Define Your Strings

Create `Localizable.strings`:

```
"welcome" = "Welcome to %@!";
"items_count" = "%d items";
"greeting" = "Hello, {name}!";
```

### 2. Generate Type-Safe Code

```bash
swift run globalingo generate
```

This creates `L10n.swift`:

```swift
enum L10n {
    static func welcome(_ p1: String) -> String
    static func itemsCount(_ p1: Int) -> String
    static func greeting(name: String) -> String
}
```

### 3. Use in Your Code

```swift
import GlobalLingo

struct ContentView: View {
    var body: some View {
        VStack {
            Text(L10n.welcome("App"))
            Text(L10n.itemsCount(5))
            Text(L10n.greeting(name: "John"))
        }
    }
}
```

## Pluralization

GlobalLingo uses ICU MessageFormat for complex plurals:

```
"messages_count" = "{count, plural, =0 {No messages} one {# message} other {# messages}}";
```

```swift
L10n.messagesCount(0)  // "No messages"
L10n.messagesCount(1)  // "1 message"
L10n.messagesCount(5)  // "5 messages"
```

### Gender Support

```
"profile_updated" = "{gender, select, male {He updated his profile} female {She updated her profile} other {They updated their profile}}";
```

## Date & Time Formatting

```swift
let date = Date()

// Locale-aware formatting
Lingo.format(date, style: .medium)  // "Feb 4, 2026"
Lingo.format(date, style: .full)    // "Wednesday, February 4, 2026"

// Relative formatting
Lingo.relative(date)  // "2 hours ago"

// Custom format
Lingo.format(date, pattern: "EEEE, MMMM d")  // "Wednesday, February 4"
```

## Number & Currency Formatting

```swift
// Numbers
Lingo.format(1234567.89)  // "1,234,567.89" (US)
                          // "1.234.567,89" (Germany)

// Currency
Lingo.currency(99.99, code: "USD")  // "$99.99"
Lingo.currency(99.99, code: "EUR")  // "€99,99"

// Percentages
Lingo.percent(0.75)  // "75%"
```

## Runtime Language Switching

```swift
// Change language at runtime
Lingo.setLanguage(.german)

// SwiftUI updates automatically
struct SettingsView: View {
    @Environment(\.locale) var locale
    
    var body: some View {
        Picker("Language", selection: $selectedLanguage) {
            ForEach(Lingo.supportedLanguages) { lang in
                Text(lang.displayName)
            }
        }
    }
}
```

## Remote Strings (OTA Updates)

Update translations without app store release:

```swift
// Configure remote source
Lingo.configure {
    $0.remoteURL = URL(string: "https://api.myapp.com/strings")
    $0.refreshInterval = .hours(24)
    $0.fallbackToBundle = true
}

// Fetch updates
await Lingo.refresh()
```

## Auto Translation

ML-powered translation suggestions during development:

```swift
// In DEBUG builds
Lingo.suggestTranslations(for: .german)
// Outputs: "welcome" → "Willkommen bei %@!"
```

## SwiftUI Integration

```swift
struct ContentView: View {
    @Localized("welcome") var welcomeText
    @LocalizedFormat("greeting", "John") var greeting
    
    var body: some View {
        VStack {
            Text(welcomeText)
            Text(greeting)
        }
    }
}
```

### Environment

```swift
ContentView()
    .environment(\.locale, Locale(identifier: "de"))
```

## String Catalog Support

GlobalLingo works with Xcode 15+ String Catalogs (`.xcstrings`):

```swift
Lingo.configure {
    $0.source = .stringCatalog
}
```

## CLI Tool

```bash
# Generate Swift code
globalingo generate --input Localizable.strings --output Sources/L10n.swift

# Validate translations
globalingo validate --report missing

# Export for translators
globalingo export --format xliff --output translations/

# Import translations
globalingo import --file translations/de.xliff

# Auto-translate (requires API key)
globalingo translate --to de,fr,es --engine deepl
```

## Best Practices

### Project Structure

```
Localization/
├── en.lproj/
│   └── Localizable.strings
├── de.lproj/
│   └── Localizable.strings
├── Generated/
│   └── L10n.swift
└── globalingo.yml
```

### Configuration File

```yaml
# globalingo.yml
input:
  - Localization/en.lproj/Localizable.strings

output:
  path: Localization/Generated/L10n.swift
  enum: L10n

languages:
  - en
  - de
  - fr
  - es
  - ja

remote:
  url: https://api.myapp.com/strings
  apiKey: ${GLOBALINGO_API_KEY}
```

## Migration Guide

### From NSLocalizedString

```swift
// Before
NSLocalizedString("key", comment: "")

// After
L10n.key
```

### From SwiftGen

GlobalLingo is a drop-in replacement with additional features.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License - see [LICENSE](LICENSE).

---

<p align="center">
  <sub>Built with ❤️ for the global iOS community</sub>
</p>

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/GlobalLingo&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/GlobalLingo&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/GlobalLingo&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/GlobalLingo&type=Date" />
 </picture>
</a>

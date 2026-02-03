<div align="center">

# 🌍 GlobalLingo

**Powerful localization and translation framework for iOS applications**

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## ✨ Features

- 🌍 **Compile-Time Safety** — Typed string keys
- 🔄 **Runtime Switching** — Change language instantly
- 📱 **Pluralization** — Full CLDR support
- 🎨 **Attributed Strings** — Rich text localization
- ⚡ **Code Generation** — From .strings files

---

## 🚀 Quick Start

```swift
import GlobalLingo

// Type-safe strings
let welcome = L10n.welcome("John") // "Welcome, John!"

// Pluralization
let items = L10n.itemCount(5) // "5 items"

// Runtime language switch
GlobalLingo.setLanguage(.spanish)
```

---

## 📄 License

MIT • [@muhittincamdali](https://github.com/muhittincamdali)

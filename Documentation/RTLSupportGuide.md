# RTL Support Guide

<!-- TOC START -->
## Table of Contents
- [RTL Support Guide](#rtl-support-guide)
- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
- [Basic Setup](#basic-setup)
  - [1. Import the Framework](#1-import-the-framework)
  - [2. Initialize the RTL Support Manager](#2-initialize-the-rtl-support-manager)
- [RTL Configuration](#rtl-configuration)
  - [Configuration Options](#configuration-options)
- [Text Direction](#text-direction)
  - [Enable RTL for Language](#enable-rtl-for-language)
  - [Text Adaptation](#text-adaptation)
- [Layout Adaptation](#layout-adaptation)
  - [Basic Layout Adaptation](#basic-layout-adaptation)
  - [SwiftUI Integration](#swiftui-integration)
  - [UIKit Integration](#uikit-integration)
- [Icon Mirroring](#icon-mirroring)
  - [Basic Icon Mirroring](#basic-icon-mirroring)
  - [Icon Mirroring Rules](#icon-mirroring-rules)
- [Navigation Adaptation](#navigation-adaptation)
  - [Navigation Bar Adaptation](#navigation-bar-adaptation)
  - [Tab Bar Adaptation](#tab-bar-adaptation)
- [Cultural Considerations](#cultural-considerations)
  - [Color Adaptation](#color-adaptation)
  - [Typography Adaptation](#typography-adaptation)
- [Testing](#testing)
  - [Unit Tests](#unit-tests)
  - [UI Tests](#ui-tests)
- [Best Practices](#best-practices)
  - [1. Configuration](#1-configuration)
  - [2. Layout Design](#2-layout-design)
  - [3. Text Handling](#3-text-handling)
  - [4. Icon and Image Handling](#4-icon-and-image-handling)
  - [5. Navigation](#5-navigation)
  - [6. Testing](#6-testing)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
    - [1. Layout Not Adapting](#1-layout-not-adapting)
    - [2. Icons Not Mirroring](#2-icons-not-mirroring)
    - [3. Text Alignment Issues](#3-text-alignment-issues)
    - [4. Navigation Problems](#4-navigation-problems)
  - [Debugging Tips](#debugging-tips)
- [Support](#support)
- [Next Steps](#next-steps)
<!-- TOC END -->


## Overview

This comprehensive guide will walk you through implementing right-to-left (RTL) language support in your iOS applications using the GlobalLingo framework. You'll learn how to handle RTL languages like Arabic, Hebrew, Persian, and Urdu.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Basic Setup](#basic-setup)
4. [RTL Configuration](#rtl-configuration)
5. [Text Direction](#text-direction)
6. [Layout Adaptation](#layout-adaptation)
7. [Icon Mirroring](#icon-mirroring)
8. [Navigation Adaptation](#navigation-adaptation)
9. [Cultural Considerations](#cultural-considerations)
10. [Testing](#testing)
11. [Best Practices](#best-practices)
12. [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have:

- **iOS 15.0+** with iOS 15.0+ SDK
- **Swift 5.9+** programming language
- **Xcode 15.0+** development environment
- **Basic understanding of RTL languages**
- **Familiarity with iOS layout systems**

## Installation

### Swift Package Manager

Add GlobalLingo to your project using Swift Package Manager:

1. In Xcode, go to **File > Add Package Dependencies**
2. Enter the repository URL: `https://github.com/muhittincamdali/GlobalLingo.git`
3. Select the version you want to use
4. Click **Add Package**

## Basic Setup

### 1. Import the Framework

```swift
import GlobalLingo
```

### 2. Initialize the RTL Support Manager

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    let rtlSupportManager = RTLSupportManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure RTL support
        setupRTLSupport()
        
        return true
    }
    
    private func setupRTLSupport() {
        let config = RTLSupportConfiguration()
        config.enableRTLSupport = true
        config.enableRTLText = true
        config.enableRTLayout = true
        config.enableRTLIcons = true
        config.enableRTLCultural = true
        config.enableRTLNavigation = true
        config.autoDetectRTL = true
        config.rtlLanguages = ["ar", "he", "fa", "ur"]
        
        rtlSupportManager.configure(config)
    }
}
```

## RTL Configuration

### Configuration Options

```swift
let config = RTLSupportConfiguration()

// Enable RTL features
config.enableRTLSupport = true
config.enableRTLText = true
config.enableRTLayout = true
config.enableRTLIcons = true
config.enableRTLCultural = true
config.enableRTLNavigation = true
config.enableRTLAnimations = true
config.enableRTLGestures = true

// Detection settings
config.autoDetectRTL = true
config.forceRTL = false

// RTL languages
config.rtlLanguages = ["ar", "he", "fa", "ur", "ps", "sd"]

// Mirroring rules
config.mirroringRules = [
    "back_button": .always,
    "forward_button": .always,
    "logo": .never,
    "profile_image": .conditional("user_preference")
]

rtlSupportManager.configure(config)
```

## Text Direction

### Enable RTL for Language

```swift
// Enable RTL for Arabic
rtlSupportManager.enableRTL(forLanguage: "ar") { result in
    switch result {
    case .success(let rtlSupport):
        print("✅ RTL enabled for Arabic")
        print("Direction: \(rtlSupport.direction)")
        print("Text alignment: \(rtlSupport.textAlignment)")
        print("Layout direction: \(rtlSupport.layoutDirection)")
    case .failure(let error):
        print("❌ RTL enablement failed: \(error)")
    }
}
```

### Text Adaptation

```swift
// Adapt text for RTL
rtlSupportManager.adaptText(
    forDirection: .rightToLeft,
    text: "Hello World"
) { result in
    switch result {
    case .success(let adaptedText):
        print("Text adapted: \(adaptedText)")
    case .failure(let error):
        print("Text adaptation failed: \(error)")
    }
}
```

## Layout Adaptation

### Basic Layout Adaptation

```swift
// Adapt layout for RTL
rtlSupportManager.adaptLayout(
    forDirection: .rightToLeft,
    components: ["navigation", "buttons", "text", "images"]
) { result in
    switch result {
    case .success(let layout):
        print("✅ RTL layout adaptation completed")
        print("Components adapted: \(layout.components)")
        print("Mirroring applied: \(layout.mirroringApplied)")
        print("Layout changes: \(layout.layoutChanges)")
    case .failure(let error):
        print("❌ RTL layout adaptation failed: \(error)")
    }
}
```

### SwiftUI Integration

```swift
struct RTLView: View {
    @StateObject private var rtlSupportManager = RTLSupportManager()
    @State private var isRTL = false
    @State private var textDirection: TextDirection = .leftToRight
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hello World")
                .font(.title)
                .multilineTextAlignment(isRTL ? .trailing : .leading)
            
            HStack {
                Button("Left") { }
                Spacer()
                Button("Right") { }
            }
            .padding()
            
            Toggle("Enable RTL", isOn: $isRTL)
                .onChange(of: isRTL) { newValue in
                    toggleRTL(enabled: newValue)
                }
        }
        .padding()
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        .onAppear {
            setupRTLSupport()
        }
    }
    
    private func setupRTLSupport() {
        let config = RTLSupportConfiguration()
        config.enableRTLSupport = true
        config.enableRTLText = true
        config.enableRTLayout = true
        rtlSupportManager.configure(config)
    }
    
    private func toggleRTL(enabled: Bool) {
        let direction: TextDirection = enabled ? .rightToLeft : .leftToRight
        textDirection = direction
        
        rtlSupportManager.adaptLayout(
            forDirection: direction,
            components: ["text", "buttons", "layout"]
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let layout):
                    print("Layout adapted successfully")
                case .failure(let error):
                    print("Layout adaptation failed: \(error)")
                }
            }
        }
    }
}
```

### UIKit Integration

```swift
class RTLViewController: UIViewController {
    private let rtlSupportManager = RTLSupportManager()
    private let welcomeLabel = UILabel()
    private let rtlSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRTLSupport()
    }
    
    private func setupRTLSupport() {
        let config = RTLSupportConfiguration()
        config.enableRTLSupport = true
        config.enableRTLText = true
        config.enableRTLayout = true
        rtlSupportManager.configure(config)
    }
    
    @objc private func rtlSwitchChanged() {
        let direction: TextDirection = rtlSwitch.isOn ? .rightToLeft : .leftToRight
        
        rtlSupportManager.adaptLayout(
            forDirection: direction,
            components: ["text", "layout"]
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let layout):
                    self?.applyRTLayout(layout)
                case .failure(let error):
                    print("RTL adaptation failed: \(error)")
                }
            }
        }
    }
    
    private func applyRTLayout(_ layout: RTLayout) {
        // Apply layout changes
        if layout.direction == .rightToLeft {
            welcomeLabel.textAlignment = .right
            view.semanticContentAttribute = .forceRightToLeft
        } else {
            welcomeLabel.textAlignment = .left
            view.semanticContentAttribute = .forceLeftToRight
        }
    }
}
```

## Icon Mirroring

### Basic Icon Mirroring

```swift
// Mirror icons for RTL
rtlSupportManager.mirrorIcons(
    forDirection: .rightToLeft
) { result in
    switch result {
    case .success(let mirroredIcons):
        print("Icons mirrored: \(mirroredIcons)")
        for icon in mirroredIcons {
            print("Mirrored icon: \(icon)")
        }
    case .failure(let error):
        print("Icon mirroring failed: \(error)")
    }
}
```

### Icon Mirroring Rules

```swift
// Define mirroring rules
let mirroringRules: [String: MirroringRule] = [
    "back_button": .always,        // Always mirror
    "forward_button": .always,     // Always mirror
    "logo": .never,               // Never mirror
    "profile_image": .auto,       // Auto-detect
    "menu_button": .conditional("user_preference") // Conditional
]

// Apply mirroring rules
for (iconName, rule) in mirroringRules {
    switch rule {
    case .always:
        // Always mirror this icon
        mirrorIcon(iconName)
    case .never:
        // Never mirror this icon
        break
    case .auto:
        // Auto-detect based on context
        autoMirrorIcon(iconName)
    case .conditional(let condition):
        // Mirror based on condition
        if shouldMirror(condition) {
            mirrorIcon(iconName)
        }
    }
}
```

## Navigation Adaptation

### Navigation Bar Adaptation

```swift
// Adapt navigation bar for RTL
func adaptNavigationBar(forDirection direction: TextDirection) {
    if direction == .rightToLeft {
        // Mirror navigation bar items
        navigationItem.leftBarButtonItem = originalRightButton
        navigationItem.rightBarButtonItem = originalLeftButton
        
        // Adjust navigation bar title alignment
        navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
    } else {
        // Restore original layout
        navigationItem.leftBarButtonItem = originalLeftButton
        navigationItem.rightBarButtonItem = originalRightButton
        
        navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
}
```

### Tab Bar Adaptation

```swift
// Adapt tab bar for RTL
func adaptTabBar(forDirection direction: TextDirection) {
    if direction == .rightToLeft {
        // Mirror tab bar items
        tabBarController?.tabBar.semanticContentAttribute = .forceRightToLeft
        
        // Reorder tab items for RTL
        let items = tabBarController?.tabBar.items ?? []
        let mirroredItems = Array(items.reversed())
        tabBarController?.setViewControllers(tabBarController?.viewControllers?.reversed(), animated: false)
    } else {
        // Restore original layout
        tabBarController?.tabBar.semanticContentAttribute = .forceLeftToRight
    }
}
```

## Cultural Considerations

### Color Adaptation

```swift
// Adapt colors for RTL cultures
func adaptColors(forDirection direction: TextDirection) -> ColorScheme {
    if direction == .rightToLeft {
        // Use colors appropriate for RTL cultures
        return ColorScheme(
            primary: UIColor.systemBlue,
            secondary: UIColor.systemGreen,
            accent: UIColor.systemOrange,
            background: UIColor.systemBackground,
            text: UIColor.label
        )
    } else {
        // Use default color scheme
        return defaultColorScheme
    }
}
```

### Typography Adaptation

```swift
// Adapt typography for RTL
func adaptTypography(forDirection direction: TextDirection) -> TypographyScheme {
    if direction == .rightToLeft {
        // Use fonts appropriate for RTL languages
        return TypographyScheme(
            titleFont: UIFont.systemFont(ofSize: 24, weight: .bold),
            bodyFont: UIFont.systemFont(ofSize: 16, weight: .regular),
            captionFont: UIFont.systemFont(ofSize: 12, weight: .light),
            lineHeight: 1.5
        )
    } else {
        // Use default typography
        return defaultTypographyScheme
    }
}
```

## Testing

### Unit Tests

```swift
class RTLSupportTests: XCTestCase {
    var rtlSupportManager: RTLSupportManager!
    
    override func setUp() {
        super.setUp()
        rtlSupportManager = RTLSupportManager()
    }
    
    override func tearDown() {
        rtlSupportManager = nil
        super.tearDown()
    }
    
    func testConfiguration() {
        let config = RTLSupportConfiguration()
        config.enableRTLSupport = true
        config.enableRTLText = true
        config.rtlLanguages = ["ar", "he"]
        
        rtlSupportManager.configure(config)
        
        // Verify configuration was applied
    }
    
    func testEnableRTL() {
        let expectation = XCTestExpectation(description: "RTL enabled")
        
        rtlSupportManager.enableRTL(forLanguage: "ar") { result in
            switch result {
            case .success(let rtlSupport):
                XCTAssertEqual(rtlSupport.language, "ar")
                XCTAssertEqual(rtlSupport.direction, .rightToLeft)
                XCTAssertTrue(rtlSupport.isEnabled)
            case .failure(let error):
                XCTFail("RTL enablement failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLayoutAdaptation() {
        let expectation = XCTestExpectation(description: "Layout adapted")
        
        rtlSupportManager.adaptLayout(
            forDirection: .rightToLeft,
            components: ["text", "buttons"]
        ) { result in
            switch result {
            case .success(let layout):
                XCTAssertEqual(layout.direction, .rightToLeft)
                XCTAssertEqual(layout.components.count, 2)
                XCTAssertTrue(layout.mirroringApplied)
            case .failure(let error):
                XCTFail("Layout adaptation failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
```

### UI Tests

```swift
class RTLUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testRTLToggle() {
        // Navigate to RTL settings
        app.buttons["Settings"].tap()
        app.buttons["RTL Support"].tap()
        
        // Toggle RTL
        app.switches["Enable RTL"].tap()
        
        // Verify layout changes
        XCTAssertTrue(app.staticTexts["مرحبا بالعالم"].exists)
    }
    
    func testRTLNavigation() {
        // Enable RTL
        app.switches["Enable RTL"].tap()
        
        // Test navigation
        app.buttons["Next"].tap()
        
        // Verify navigation direction
        XCTAssertTrue(app.buttons["Previous"].exists)
    }
}
```

## Best Practices

### 1. Configuration

- **Always configure the RTL support manager before use**
- **Enable only the features you need**
- **Set appropriate mirroring rules**
- **Test with actual RTL languages**

### 2. Layout Design

- **Use Auto Layout constraints that work in both directions**
- **Avoid hard-coded left/right positioning**
- **Use semantic content attributes**
- **Test layout in both LTR and RTL modes**

### 3. Text Handling

- **Use appropriate text alignment**
- **Handle text direction properly**
- **Test with actual RTL text**
- **Consider text length differences**

### 4. Icon and Image Handling

- **Define clear mirroring rules**
- **Test icon mirroring thoroughly**
- **Consider cultural appropriateness**
- **Handle images that shouldn't be mirrored**

### 5. Navigation

- **Adapt navigation patterns for RTL**
- **Test navigation flow in both directions**
- **Consider cultural navigation preferences**
- **Handle back/forward navigation properly**

### 6. Testing

- **Test with actual RTL languages**
- **Test layout in both directions**
- **Test navigation patterns**
- **Test with different screen sizes**

## Troubleshooting

### Common Issues

#### 1. Layout Not Adapting

**Problem**: Layout doesn't change when switching to RTL.

**Solutions**:
- Verify RTL support is enabled
- Check Auto Layout constraints
- Use semantic content attributes
- Test with actual RTL languages

#### 2. Icons Not Mirroring

**Problem**: Icons don't mirror correctly in RTL.

**Solutions**:
- Check mirroring rules
- Verify icon names match rules
- Test with different icon types
- Handle conditional mirroring

#### 3. Text Alignment Issues

**Problem**: Text alignment is incorrect in RTL.

**Solutions**:
- Use appropriate text alignment
- Check text direction settings
- Test with actual RTL text
- Verify font support

#### 4. Navigation Problems

**Problem**: Navigation doesn't work correctly in RTL.

**Solutions**:
- Adapt navigation bar items
- Test navigation flow
- Handle back/forward properly
- Consider cultural preferences

### Debugging Tips

1. **Enable debug logging**:
```swift
let config = RTLSupportConfiguration()
config.enableDebugLogging = true
```

2. **Check RTL support**:
```swift
if rtlSupportManager.isRTLSupported(forLanguage: "ar") {
    print("RTL supported for Arabic")
}
```

3. **Test layout direction**:
```swift
let direction = rtlSupportManager.getRTLSupport(forLanguage: "ar")?.direction
print("Layout direction: \(direction)")
```

## Support

For additional support and documentation:

- [API Reference](RTLSupportAPI.md)
- [Examples](../Examples/RTLSupportExamples/)
- [GitHub Issues](https://github.com/muhittincamdali/GlobalLingo/issues)
- [Community Discussions](https://github.com/muhittincamdali/GlobalLingo/discussions)

## Next Steps

Now that you have a solid understanding of RTL support with GlobalLingo, you can:

1. **Explore cultural adaptation** features
2. **Implement advanced RTL patterns**
3. **Add RTL testing** to your workflow
4. **Contribute to the project** by reporting issues or submitting pull requests
5. **Share your experience** with the community

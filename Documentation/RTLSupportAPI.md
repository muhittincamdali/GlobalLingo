# RTL Support API

## Overview

The RTL Support API provides comprehensive right-to-left language support for iOS applications, including text direction, layout adaptation, icon mirroring, and cultural considerations.

## Core Classes

### RTLSupportManager

The main RTL support manager that orchestrates all RTL-related operations.

```swift
public class RTLSupportManager {
    public init()
    public func configure(_ configuration: RTLSupportConfiguration)
    public func enableRTL(forLanguage language: String, completion: @escaping (Result<RTLSupport, RTLError>) -> Void)
    public func disableRTL(forLanguage language: String, completion: @escaping (Result<Void, RTLError>) -> Void)
    public func adaptLayout(forDirection direction: TextDirection, components: [String], completion: @escaping (Result<RTLayout, RTLError>) -> Void)
    public func mirrorIcons(forDirection direction: TextDirection, completion: @escaping (Result<[String], RTLError>) -> Void)
    public func adaptText(forDirection direction: TextDirection, text: String, completion: @escaping (Result<String, RTLError>) -> Void)
    public func isRTLSupported(forLanguage language: String) -> Bool
    public func getRTLSupport(forLanguage language: String) -> RTLSupport?
}
```

### RTLSupportConfiguration

Configuration options for the RTL support manager.

```swift
public struct RTLSupportConfiguration {
    public var enableRTLSupport: Bool
    public var enableRTLText: Bool
    public var enableRTLayout: Bool
    public var enableRTLIcons: Bool
    public var enableRTLCultural: Bool
    public var enableRTLNavigation: Bool
    public var enableRTLAnimations: Bool
    public var enableRTLGestures: Bool
    public var autoDetectRTL: Bool
    public var forceRTL: Bool
    public var rtlLanguages: [String]
    public var mirroringRules: [String: MirroringRule]
}
```

### RTLSupport

Represents RTL support for a specific language.

```swift
public struct RTLSupport {
    public let language: String
    public let direction: TextDirection
    public let textAlignment: NSTextAlignment
    public let layoutDirection: UIUserInterfaceLayoutDirection
    public let isEnabled: Bool
    public let culturalAdaptations: [String: Any]
    public let mirroringApplied: Bool
    public let timestamp: Date
}
```

### RTLayout

Represents RTL layout adaptation results.

```swift
public struct RTLayout {
    public let direction: TextDirection
    public let components: [String]
    public let mirroringApplied: Bool
    public let layoutChanges: [String: Any]
    public let constraints: [String: NSLayoutConstraint]
    public let animations: [String: CAAnimation]
}
```

### TextDirection

Enumeration of text directions.

```swift
public enum TextDirection {
    case leftToRight
    case rightToLeft
    case natural
    case inherit
}
```

### MirroringRule

Enumeration of mirroring rule types.

```swift
public enum MirroringRule {
    case always
    case never
    case auto
    case conditional(String)
}
```

### RTLError

Enumeration of RTL error types.

```swift
public enum RTLError: Error {
    case languageNotSupported(String)
    case configurationError(String)
    case layoutAdaptationFailed(String)
    case iconMirroringFailed(String)
    case textAdaptationFailed(String)
    case culturalAdaptationFailed(String)
    case navigationAdaptationFailed(String)
    case animationAdaptationFailed(String)
}
```

## Usage Examples

### Basic RTL Support

```swift
let rtlSupportManager = RTLSupportManager()

let config = RTLSupportConfiguration()
config.enableRTLSupport = true
config.enableRTLText = true
config.enableRTLayout = true
config.enableRTLIcons = true
config.autoDetectRTL = true
config.rtlLanguages = ["ar", "he", "fa", "ur"]

rtlSupportManager.configure(config)

// Enable RTL for Arabic
rtlSupportManager.enableRTL(forLanguage: "ar") { result in
    switch result {
    case .success(let rtlSupport):
        print("RTL enabled for Arabic")
        print("Direction: \(rtlSupport.direction)")
        print("Text alignment: \(rtlSupport.textAlignment)")
        print("Layout direction: \(rtlSupport.layoutDirection)")
    case .failure(let error):
        print("RTL enablement failed: \(error)")
    }
}
```

### Layout Adaptation

```swift
// Adapt layout for RTL
rtlSupportManager.adaptLayout(
    forDirection: .rightToLeft,
    components: ["navigation", "buttons", "text", "images"]
) { result in
    switch result {
    case .success(let layout):
        print("RTL layout adaptation completed")
        print("Components adapted: \(layout.components)")
        print("Mirroring applied: \(layout.mirroringApplied)")
        print("Layout changes: \(layout.layoutChanges)")
    case .failure(let error):
        print("RTL layout adaptation failed: \(error)")
    }
}
```

### Icon Mirroring

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

## Advanced Features

### Cultural Adaptation

```swift
public protocol RTLCulturalAdaptation {
    func adaptColors(forDirection: TextDirection) -> ColorScheme
    func adaptTypography(forDirection: TextDirection) -> TypographyScheme
    func adaptSpacing(forDirection: TextDirection) -> SpacingScheme
    func adaptAnimations(forDirection: TextDirection) -> AnimationScheme
}
```

### Navigation Adaptation

```swift
public protocol RTLNavigationAdaptation {
    func adaptNavigationBar(forDirection: TextDirection)
    func adaptTabBar(forDirection: TextDirection)
    func adaptToolbar(forDirection: TextDirection)
    func adaptMenu(forDirection: TextDirection)
}
```

### Gesture Adaptation

```swift
public protocol RTLGestureAdaptation {
    func adaptSwipeGestures(forDirection: TextDirection)
    func adaptPanGestures(forDirection: TextDirection)
    func adaptTapGestures(forDirection: TextDirection)
    func adaptLongPressGestures(forDirection: TextDirection)
}
```

### Animation Adaptation

```swift
public protocol RTLAnimationAdaptation {
    func adaptTransitions(forDirection: TextDirection)
    func adaptSpringAnimations(forDirection: TextDirection)
    func adaptKeyframeAnimations(forDirection: TextDirection)
    func adaptCoreAnimation(forDirection: TextDirection)
}
```

## Integration Examples

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

## Testing

### Unit Tests

```swift
class RTLSupportManagerTests: XCTestCase {
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
        // Add assertions based on your implementation
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

## Best Practices

1. **Always configure the RTL support manager before use**
2. **Test RTL support with actual RTL languages**
3. **Implement proper error handling for all RTL operations**
4. **Use semantic content attributes correctly**
5. **Test layout adaptation thoroughly**
6. **Handle icon mirroring appropriately**
7. **Consider cultural adaptations**
8. **Test navigation in RTL mode**
9. **Verify gesture behavior in RTL**
10. **Monitor performance in RTL mode**

## Migration Guide

### From Version 1.0 to 2.0

1. **Update configuration initialization**
2. **Replace deprecated methods**
3. **Update error handling**
4. **Migrate to new API structure**

### Breaking Changes

- `RTLSupportManager.init()` now requires configuration
- Error types have been reorganized
- Some method signatures have changed

## Troubleshooting

### Common Issues

1. **Layout not adapting correctly**
2. **Icons not mirroring**
3. **Text alignment issues**
4. **Navigation problems**
5. **Animation direction issues**

### Solutions

1. **Verify semantic content attributes**
2. **Check icon mirroring rules**
3. **Test text alignment thoroughly**
4. **Adapt navigation components**
5. **Review animation directions**

## Support

For additional support and documentation:

- [Getting Started Guide](GettingStarted.md)
- [RTL Support Guide](RTLSupportGuide.md)
- [API Reference](API.md)
- [Examples](../Examples/RTLSupportExamples/)
- [GitHub Issues](https://github.com/muhittincamdali/GlobalLingo/issues)

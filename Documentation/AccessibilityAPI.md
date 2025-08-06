# Accessibility API

## Overview

The Accessibility API provides comprehensive accessibility features for iOS applications, including VoiceOver support, Dynamic Type, accessibility labels, and WCAG compliance tools.

## Core Classes

### AccessibilityManager

The main accessibility manager that orchestrates all accessibility-related operations.

```swift
public class AccessibilityManager {
    public init()
    public func configure(_ configuration: AccessibilityConfiguration)
    public func enableAccessibility(forElement element: UIView, completion: @escaping (Result<AccessibilityElement, AccessibilityError>) -> Void)
    public func disableAccessibility(forElement element: UIView, completion: @escaping (Result<Void, AccessibilityError>) -> Void)
    public func setAccessibilityLabel(_ label: String, forElement element: UIView, completion: @escaping (Result<Void, AccessibilityError>) -> Void)
    public func setAccessibilityHint(_ hint: String, forElement element: UIView, completion: @escaping (Result<Void, AccessibilityError>) -> Void)
    public func setAccessibilityTraits(_ traits: UIAccessibilityTraits, forElement element: UIView, completion: @escaping (Result<Void, AccessibilityError>) -> Void)
    public func validateAccessibility(forElement element: UIView) -> AccessibilityValidationResult
    public func generateAccessibilityReport() -> AccessibilityReport
    public func isAccessibilityEnabled() -> Bool
    public func getAccessibilityElements() -> [AccessibilityElement]
}
```

### AccessibilityConfiguration

Configuration options for the accessibility manager.

```swift
public struct AccessibilityConfiguration {
    public var enableVoiceOverSupport: Bool
    public var enableDynamicType: Bool
    public var enableAccessibilityLabels: Bool
    public var enableAccessibilityHints: Bool
    public var enableAccessibilityTraits: Bool
    public var enableWCAGCompliance: Bool
    public var enableAccessibilityTesting: Bool
    public var enableAccessibilityReporting: Bool
    public var enableAccessibilityAuditing: Bool
    public var enableAccessibilityTraining: Bool
    public var accessibilityLevel: AccessibilityLevel
    public var supportedLanguages: [String]
}
```

### AccessibilityElement

Represents an accessibility element.

```swift
public struct AccessibilityElement {
    public let element: UIView
    public let label: String?
    public let hint: String?
    public let traits: UIAccessibilityTraits
    public let isAccessibilityElement: Bool
    public let accessibilityFrame: CGRect
    public let accessibilityPath: UIBezierPath?
    public let accessibilityActivationPoint: CGPoint
    public let accessibilityLanguage: String?
    public let accessibilityElementsHidden: Bool
    public let accessibilityViewIsModal: Bool
    public let shouldGroupAccessibilityChildren: Bool
}
```

### AccessibilityLevel

Enumeration of accessibility levels.

```swift
public enum AccessibilityLevel {
    case basic
    case standard
    case enhanced
    case comprehensive
}
```

### AccessibilityValidationResult

Represents accessibility validation results.

```swift
public struct AccessibilityValidationResult {
    public let isValid: Bool
    public let score: Double
    public let issues: [AccessibilityIssue]
    public let recommendations: [AccessibilityRecommendation]
    public let wcagCompliance: WCAGCompliance
    public let timestamp: Date
}
```

### AccessibilityIssue

Represents an accessibility issue.

```swift
public struct AccessibilityIssue {
    public let type: AccessibilityIssueType
    public let severity: AccessibilityIssueSeverity
    public let element: UIView?
    public let description: String
    public let suggestion: String
    public let wcagCriteria: [WCAGCriterion]
}
```

### AccessibilityIssueType

Enumeration of accessibility issue types.

```swift
public enum AccessibilityIssueType {
    case missingLabel
    case missingHint
    case insufficientContrast
    case smallTouchTarget
    case missingTraits
    case poorNavigation
    case inaccessibleElement
    case dynamicTypeIssue
    case voiceOverIssue
}
```

### AccessibilityIssueSeverity

Enumeration of accessibility issue severities.

```swift
public enum AccessibilityIssueSeverity {
    case low
    case medium
    case high
    case critical
}
```

### WCAGCompliance

Represents WCAG compliance status.

```swift
public struct WCAGCompliance {
    public let level: WCAGLevel
    public let criteria: [WCAGCriterion]
    public let complianceScore: Double
    public let nonCompliantElements: [String]
    public let recommendations: [String]
}
```

### WCAGLevel

Enumeration of WCAG levels.

```swift
public enum WCAGLevel {
    case A
    case AA
    case AAA
}
```

### WCAGCriterion

Represents a WCAG criterion.

```swift
public struct WCAGCriterion {
    public let id: String
    public let title: String
    public let level: WCAGLevel
    public let description: String
    public let isCompliant: Bool
    public let issues: [String]
}
```

### AccessibilityError

Enumeration of accessibility error types.

```swift
public enum AccessibilityError: Error {
    case elementNotFound(UIView)
    case invalidConfiguration(String)
    case validationFailed([AccessibilityIssue])
    case voiceOverNotAvailable
    case dynamicTypeNotSupported
    case wcagComplianceFailed(WCAGCompliance)
    case accessibilityNotEnabled
    case elementNotAccessible(UIView)
}
```

## Usage Examples

### Basic Accessibility Setup

```swift
let accessibilityManager = AccessibilityManager()

let config = AccessibilityConfiguration()
config.enableVoiceOverSupport = true
config.enableDynamicType = true
config.enableAccessibilityLabels = true
config.enableAccessibilityHints = true
config.enableWCAGCompliance = true
config.accessibilityLevel = .standard
config.supportedLanguages = ["en", "es", "fr", "de"]

accessibilityManager.configure(config)

// Enable accessibility for element
accessibilityManager.enableAccessibility(forElement: button) { result in
    switch result {
    case .success(let element):
        print("✅ Accessibility enabled")
        print("Label: \(element.label ?? "No label")")
        print("Hint: \(element.hint ?? "No hint")")
        print("Traits: \(element.traits)")
    case .failure(let error):
        print("❌ Accessibility enablement failed: \(error)")
    }
}
```

### Accessibility Labels and Hints

```swift
// Set accessibility label
accessibilityManager.setAccessibilityLabel(
    "Submit button for user registration form",
    forElement: submitButton
) { result in
    switch result {
    case .success:
        print("✅ Accessibility label set")
    case .failure(let error):
        print("❌ Label setting failed: \(error)")
    }
}

// Set accessibility hint
accessibilityManager.setAccessibilityHint(
    "Double tap to submit your registration information",
    forElement: submitButton
) { result in
    switch result {
    case .success:
        print("✅ Accessibility hint set")
    case .failure(let error):
        print("❌ Hint setting failed: \(error)")
    }
}

// Set accessibility traits
accessibilityManager.setAccessibilityTraits(
    [.button, .allowsDirectInteraction],
    forElement: submitButton
) { result in
    switch result {
    case .success:
        print("✅ Accessibility traits set")
    case .failure(let error):
        print("❌ Traits setting failed: \(error)")
    }
}
```

### Accessibility Validation

```swift
// Validate accessibility for element
let validationResult = accessibilityManager.validateAccessibility(forElement: button)

if validationResult.isValid {
    print("✅ Accessibility validation passed")
    print("Score: \(validationResult.score)")
} else {
    print("❌ Accessibility validation failed")
    for issue in validationResult.issues {
        print("- \(issue.type): \(issue.description)")
        print("  Suggestion: \(issue.suggestion)")
    }
}

// Check WCAG compliance
let wcagCompliance = validationResult.wcagCompliance
print("WCAG \(wcagCompliance.level) Compliance: \(wcagCompliance.complianceScore)%")

if wcagCompliance.complianceScore < 100 {
    print("Non-compliant elements:")
    for element in wcagCompliance.nonCompliantElements {
        print("- \(element)")
    }
}
```

### SwiftUI Integration

```swift
struct AccessibilityView: View {
    @StateObject private var accessibilityManager = AccessibilityManager()
    @State private var validationResult: AccessibilityValidationResult?
    @State private var isAccessibilityEnabled = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Submit") {
                // Action
            }
            .accessibilityLabel("Submit button for user registration")
            .accessibilityHint("Double tap to submit your information")
            .accessibilityAddTraits(.isButton)
            
            Button("Cancel") {
                // Action
            }
            .accessibilityLabel("Cancel button")
            .accessibilityHint("Double tap to cancel registration")
            .accessibilityAddTraits(.isButton)
            
            Toggle("Enable Accessibility", isOn: $isAccessibilityEnabled)
                .onChange(of: isAccessibilityEnabled) { newValue in
                    toggleAccessibility(enabled: newValue)
                }
            
            Button("Validate Accessibility") {
                validateAccessibility()
            }
            .buttonStyle(.bordered)
            
            if let result = validationResult {
                AccessibilityValidationView(result: result)
            }
        }
        .padding()
        .onAppear {
            setupAccessibilityManager()
        }
    }
    
    private func setupAccessibilityManager() {
        let config = AccessibilityConfiguration()
        config.enableVoiceOverSupport = true
        config.enableDynamicType = true
        config.enableWCAGCompliance = true
        accessibilityManager.configure(config)
    }
    
    private func toggleAccessibility(enabled: Bool) {
        // Toggle accessibility features
        if enabled {
            print("Accessibility enabled")
        } else {
            print("Accessibility disabled")
        }
    }
    
    private func validateAccessibility() {
        // Validate accessibility for the view
        let result = accessibilityManager.validateAccessibility(forElement: UIView())
        validationResult = result
    }
}

struct AccessibilityValidationView: View {
    let result: AccessibilityValidationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Accessibility Validation")
                .font(.headline)
            
            HStack {
                Text("Status:")
                Spacer()
                Text(result.isValid ? "✅ Valid" : "❌ Invalid")
                    .foregroundColor(result.isValid ? .green : .red)
            }
            
            HStack {
                Text("Score:")
                Spacer()
                Text("\(Int(result.score))%")
            }
            
            if !result.issues.isEmpty {
                Text("Issues:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(result.issues, id: \.description) { issue in
                    VStack(alignment: .leading) {
                        Text(issue.description)
                            .font(.caption)
                        Text("Suggestion: \(issue.suggestion)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
```

### UIKit Integration

```swift
class AccessibilityViewController: UIViewController {
    private let accessibilityManager = AccessibilityManager()
    private let submitButton = UIButton()
    private let validationLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityManager()
        setupAccessibility()
    }
    
    private func setupAccessibilityManager() {
        let config = AccessibilityConfiguration()
        config.enableVoiceOverSupport = true
        config.enableDynamicType = true
        config.enableWCAGCompliance = true
        accessibilityManager.configure(config)
    }
    
    private func setupAccessibility() {
        // Enable accessibility for button
        accessibilityManager.enableAccessibility(forElement: submitButton) { result in
            switch result {
            case .success(let element):
                print("Accessibility enabled for button")
            case .failure(let error):
                print("Accessibility setup failed: \(error)")
            }
        }
        
        // Set accessibility properties
        accessibilityManager.setAccessibilityLabel(
            "Submit button for user registration form",
            forElement: submitButton
        ) { _ in }
        
        accessibilityManager.setAccessibilityHint(
            "Double tap to submit your registration information",
            forElement: submitButton
        ) { _ in }
        
        accessibilityManager.setAccessibilityTraits(
            [.button, .allowsDirectInteraction],
            forElement: submitButton
        ) { _ in }
    }
    
    @objc private func validateButtonTapped() {
        let result = accessibilityManager.validateAccessibility(forElement: submitButton)
        displayValidationResult(result)
    }
    
    private func displayValidationResult(_ result: AccessibilityValidationResult) {
        let text = """
        Accessibility Validation:
        Status: \(result.isValid ? "Valid" : "Invalid")
        Score: \(Int(result.score))%
        Issues: \(result.issues.count)
        """
        
        validationLabel.text = text
        
        if !result.issues.isEmpty {
            print("Accessibility issues found:")
            for issue in result.issues {
                print("- \(issue.description)")
                print("  Suggestion: \(issue.suggestion)")
            }
        }
    }
}
```

## Testing

### Unit Tests

```swift
class AccessibilityTests: XCTestCase {
    var accessibilityManager: AccessibilityManager!
    var testButton: UIButton!
    
    override func setUp() {
        super.setUp()
        accessibilityManager = AccessibilityManager()
        testButton = UIButton()
    }
    
    override func tearDown() {
        accessibilityManager = nil
        testButton = nil
        super.tearDown()
    }
    
    func testConfiguration() {
        let config = AccessibilityConfiguration()
        config.enableVoiceOverSupport = true
        config.enableDynamicType = true
        config.accessibilityLevel = .standard
        
        accessibilityManager.configure(config)
        
        // Verify configuration was applied
    }
    
    func testEnableAccessibility() {
        let expectation = XCTestExpectation(description: "Accessibility enabled")
        
        accessibilityManager.enableAccessibility(forElement: testButton) { result in
            switch result {
            case .success(let element):
                XCTAssertEqual(element.element, self.testButton)
                XCTAssertTrue(element.isAccessibilityElement)
            case .failure(let error):
                XCTFail("Accessibility enablement failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSetAccessibilityLabel() {
        let expectation = XCTestExpectation(description: "Label set")
        
        accessibilityManager.setAccessibilityLabel(
            "Test button",
            forElement: testButton
        ) { result in
            switch result {
            case .success:
                XCTAssertEqual(self.testButton.accessibilityLabel, "Test button")
            case .failure(let error):
                XCTFail("Label setting failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAccessibilityValidation() {
        let result = accessibilityManager.validateAccessibility(forElement: testButton)
        
        // Test validation result
        XCTAssertNotNil(result)
        XCTAssertNotNil(result.score)
        XCTAssertNotNil(result.issues)
    }
}
```

## Best Practices

### 1. Configuration

- **Always configure the accessibility manager before use**
- **Enable appropriate accessibility features**
- **Set appropriate accessibility levels**
- **Support multiple languages**

### 2. VoiceOver Support

- **Provide clear, descriptive labels**
- **Use appropriate accessibility hints**
- **Set correct accessibility traits**
- **Test with VoiceOver enabled**

### 3. Dynamic Type

- **Support all Dynamic Type sizes**
- **Use system fonts when possible**
- **Test with different text sizes**
- **Ensure text remains readable**

### 4. WCAG Compliance

- **Aim for WCAG AA compliance**
- **Test color contrast ratios**
- **Ensure keyboard navigation**
- **Provide alternative text**

### 5. Testing

- **Test with accessibility features enabled**
- **Use accessibility testing tools**
- **Test with different devices**
- **Get feedback from users with disabilities**

## Troubleshooting

### Common Issues

#### 1. VoiceOver Not Working

**Problem**: VoiceOver doesn't read elements correctly.

**Solutions**:
- Check accessibility labels
- Verify accessibility traits
- Test with VoiceOver enabled
- Ensure elements are accessible

#### 2. Dynamic Type Issues

**Problem**: Text doesn't scale properly with Dynamic Type.

**Solutions**:
- Use system fonts
- Support all text sizes
- Test with different sizes
- Use Auto Layout properly

#### 3. WCAG Compliance Issues

**Problem**: App doesn't meet WCAG standards.

**Solutions**:
- Check color contrast
- Ensure keyboard navigation
- Provide alternative text
- Test with accessibility tools

#### 4. Validation Errors

**Problem**: Accessibility validation fails.

**Solutions**:
- Fix missing labels
- Add accessibility hints
- Set correct traits
- Improve contrast ratios

### Debugging Tips

1. **Enable accessibility debugging**:
```swift
let config = AccessibilityConfiguration()
config.enableAccessibilityTesting = true
```

2. **Check accessibility status**:
```swift
if accessibilityManager.isAccessibilityEnabled() {
    print("Accessibility is enabled")
}
```

3. **Generate accessibility report**:
```swift
let report = accessibilityManager.generateAccessibilityReport()
print("Accessibility report: \(report)")
```

## Support

For additional support and documentation:

- [Getting Started Guide](GettingStarted.md)
- [Accessibility Guide](AccessibilityGuide.md)
- [API Reference](API.md)
- [Examples](../Examples/AccessibilityExamples/)
- [GitHub Issues](https://github.com/muhittincamdali/GlobalLingo/issues)

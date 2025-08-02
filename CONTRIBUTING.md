# 🤝 Contributing to GlobalLingo

Thank you for your interest in contributing to GlobalLingo! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Types of Contributions](#types-of-contributions)
- [Contribution Process](#contribution-process)
- [Development Environment](#development-environment)
- [Code Standards](#code-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)

## 🎯 Types of Contributions

### 🐛 Bug Reports
- **Clear Description**: Provide a clear and descriptive title
- **Reproduction Steps**: Include steps to reproduce the issue
- **Expected vs Actual**: Describe expected vs actual behavior
- **Environment Info**: Include OS, device, app version
- **Screenshots**: Add screenshots if applicable

### 💡 Feature Requests
- **Problem Statement**: Clearly describe the problem
- **Proposed Solution**: Suggest a solution or feature
- **Use Cases**: Provide real-world use cases
- **Mockups**: Include UI mockups if applicable

### 📚 Documentation
- **API Documentation**: Update API reference docs
- **User Guides**: Improve user-facing documentation
- **Code Comments**: Add inline code documentation
- **README Updates**: Enhance project documentation

### 🧪 Tests
- **Unit Tests**: Add tests for new features
- **Integration Tests**: Test component interactions
- **Performance Tests**: Benchmark critical paths
- **UI Tests**: Test user interface flows

## 🔄 Contribution Process

### 1. Fork the Repository
```bash
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo
```

### 2. Create Feature Branch
```bash
git checkout -b feature/amazing-feature
# or
git checkout -b fix/bug-fix
```

### 3. Make Changes
- Write clean, well-documented code
- Follow the coding standards below
- Add tests for new functionality
- Update documentation as needed

### 4. Commit Changes
```bash
git add .
git commit -m "feat: add amazing feature"
git commit -m "fix: resolve translation bug"
git commit -m "docs: update API documentation"
```

### 5. Push to Branch
```bash
git push origin feature/amazing-feature
```

### 6. Open Pull Request
- Provide a clear description of changes
- Include any relevant issue numbers
- Add screenshots for UI changes
- Ensure all tests pass

## 🛠️ Development Environment

### Prerequisites
- **Xcode 15.0+**: Latest Xcode version
- **iOS 15.0+**: Target iOS version
- **Swift 5.9+**: Latest Swift version
- **Git**: Version control

### Setup
```bash
# Clone repository
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo

# Install dependencies
swift package resolve

# Open in Xcode
open GlobalLingo.xcodeproj
```

### Project Structure
```
GlobalLingo/
├── Sources/
│   ├── Core/
│   ├── Features/
│   ├── UI/
│   └── Services/
├── Tests/
├── Documentation/
└── Resources/
```

## 📝 Code Standards

### Swift Style Guide
- **Naming**: Use descriptive names for variables, functions, and classes
- **Indentation**: Use 4 spaces for indentation
- **Line Length**: Keep lines under 120 characters
- **Comments**: Add comments for complex logic

### Architecture Principles
- **Clean Architecture**: Follow Domain, Data, Presentation layers
- **SOLID Principles**: Apply SOLID design principles
- **Dependency Injection**: Use DI for testability
- **Protocol-Oriented**: Prefer protocols over classes

### Code Example
```swift
// ✅ Good
protocol TranslationServiceProtocol {
    func translate(text: String, from: Language, to: Language) async throws -> String
}

class TranslationService: TranslationServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func translate(text: String, from: Language, to: Language) async throws -> String {
        // Implementation
    }
}

// ❌ Bad
class TranslationService {
    func translate(text: String, from: String, to: String) -> String {
        // Implementation without protocols
    }
}
```

## 🧪 Testing Guidelines

### Unit Tests
- **Coverage**: Aim for 100% code coverage
- **Naming**: Use descriptive test names
- **Structure**: Follow Given-When-Then pattern
- **Mocking**: Use mocks for external dependencies

### Test Example
```swift
class TranslationServiceTests: XCTestCase {
    func testTranslateTextSuccess() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let service = TranslationService(networkService: mockNetworkService)
        
        // When
        let result = try await service.translate(
            text: "Hello",
            from: .english,
            to: .spanish
        )
        
        // Then
        XCTAssertEqual(result, "Hola")
    }
}
```

### Performance Tests
```swift
func testTranslationPerformance() {
    measure {
        // Performance test implementation
    }
}
```

## 📚 Documentation Standards

### Code Documentation
- **Header Comments**: Document public interfaces
- **Inline Comments**: Explain complex logic
- **API Documentation**: Use Swift documentation comments

### Documentation Example
```swift
/// Translates text from one language to another
/// - Parameters:
///   - text: The text to translate
///   - from: Source language
///   - to: Target language
/// - Returns: Translated text
/// - Throws: TranslationError if translation fails
func translate(text: String, from: Language, to: Language) async throws -> String {
    // Implementation
}
```

### README Updates
- **Feature Documentation**: Document new features
- **Usage Examples**: Provide code examples
- **Installation**: Update installation instructions
- **Changelog**: Update version history

## 🔍 Review Process

### Pull Request Review
- **Code Review**: All PRs require review
- **Automated Tests**: Must pass all tests
- **Documentation**: Update docs for new features
- **Performance**: Ensure no performance regressions

### Review Checklist
- [ ] Code follows style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes (or documented)
- [ ] Performance impact considered

## 🚀 Release Process

### Versioning
- **Semantic Versioning**: Follow MAJOR.MINOR.PATCH
- **Changelog**: Update CHANGELOG.md
- **Release Notes**: Document breaking changes

### Release Steps
1. **Update Version**: Bump version numbers
2. **Update Changelog**: Document changes
3. **Create Release**: Tag and release on GitHub
4. **Update Documentation**: Update README if needed

## 📞 Getting Help

### Communication Channels
- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and discussions
- **Pull Requests**: For code contributions

### Code of Conduct
- **Respect**: Treat all contributors with respect
- **Inclusive**: Welcome contributors from all backgrounds
- **Professional**: Maintain professional communication

## 🙏 Recognition

### Contributors
- **Code Contributors**: Listed in GitHub contributors
- **Documentation**: Credit in documentation
- **Special Thanks**: Recognition in README

### Contribution Levels
- **Bronze**: 1-5 contributions
- **Silver**: 6-20 contributions
- **Gold**: 21+ contributions

---

**Thank you for contributing to GlobalLingo! 🌍**

For questions or support, please open an issue or start a discussion.

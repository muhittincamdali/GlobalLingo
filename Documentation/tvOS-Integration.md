# =ú tvOS Integration Guide

Complete guide for integrating GlobalLingo into your tvOS applications.

## Prerequisites

- tvOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/GlobalLingo.git", from: "2.0.0")
]
```

## Basic Integration

```swift
import UIKit
import GlobalLingo

class ViewController: UIViewController {
    private let globalLingo = GlobalLingoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlobalLingo()
    }
    
    private func setupGlobalLingo() {
        globalLingo.start { result in
            switch result {
            case .success:
                print(" GlobalLingo started for tvOS")
            case .failure(let error):
                print("L Failed to start: \(error)")
            }
        }
    }
}
```

## Media Translation

```swift
class MediaTranslationController: UIViewController {
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func translateSubtitle(_ text: String) {
        globalLingo.translate(
            text: text,
            to: "es",
            from: "en"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self.subtitleLabel.text = translation.translatedText
                case .failure(let error):
                    print("Subtitle translation failed: \(error)")
                }
            }
        }
    }
}
```

For more examples, see [Basic Examples](../Examples/BasicExamples.md).
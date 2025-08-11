import Foundation
import GlobalLingo

/// Basic example demonstrating the core functionality of GlobalLingo
@main
struct BasicExample {
    static func main() {
        print("🚀 GlobalLingo Basic Example")
        
        // Initialize the framework
        let framework = GlobalLingo()
        
        // Configure with default settings
        framework.configure()
        
        print("✅ Framework configured successfully")
        
        // Demonstrate basic functionality
        demonstrateBasicFeatures(framework)
    }
    
    static func demonstrateBasicFeatures(_ framework: GlobalLingo) {
        print("\n📱 Demonstrating basic features...")
        
        // Add your example code here
        print("🎯 Feature 1: Core functionality")
        print("🎯 Feature 2: Configuration")
        print("🎯 Feature 3: Error handling")
        
        print("\n✨ Basic example completed successfully!")
    }
}

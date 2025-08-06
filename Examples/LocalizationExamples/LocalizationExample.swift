import SwiftUI
import GlobalLingo

struct LocalizationExample: View {
    @State private var currentLanguage = "en"
    @State private var showLanguageSelector = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Localization Examples")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Language Selector
            VStack(spacing: 15) {
                Text("Language Selection")
                    .font(.headline)
                
                HStack(spacing: 15) {
                    Button("English") {
                        currentLanguage = "en"
                    }
                    .buttonStyle(.borderedProminent)
                    .background(currentLanguage == "en" ? Color.blue : Color.clear)
                    
                    Button("Español") {
                        currentLanguage = "es"
                    }
                    .buttonStyle(.bordered)
                    .background(currentLanguage == "es" ? Color.blue : Color.clear)
                    
                    Button("Français") {
                        currentLanguage = "fr"
                    }
                    .buttonStyle(.bordered)
                    .background(currentLanguage == "fr" ? Color.blue : Color.clear)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            // Localized Content
            VStack(spacing: 20) {
                Text("Localized Content")
                    .font(.headline)
                
                // Welcome Message
                LocalizedText(
                    key: "welcome_message",
                    language: currentLanguage,
                    fallback: "Welcome to our app!"
                )
                .font(.title2)
                .multilineTextAlignment(.center)
                
                // User Count
                LocalizedText(
                    key: "user_count",
                    parameters: ["count": "1,234"],
                    language: currentLanguage,
                    fallback: "1,234 users"
                )
                .font(.body)
                
                // Settings
                LocalizedText(
                    key: "settings_title",
                    language: currentLanguage,
                    fallback: "Settings"
                )
                .font(.headline)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            // Pluralization Example
            VStack(spacing: 15) {
                Text("Pluralization")
                    .font(.headline)
                
                ForEach([0, 1, 5, 10], id: \.self) { count in
                    LocalizedText(
                        key: "item_count",
                        parameters: ["count": "\(count)"],
                        language: currentLanguage,
                        fallback: "\(count) items"
                    )
                    .font(.caption)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            Spacer()
        }
        .padding()
    }
}

struct LocalizedText: View {
    let key: String
    var parameters: [String: String] = [:]
    let language: String
    let fallback: String
    
    var body: some View {
        Text(localizedString)
    }
    
    private var localizedString: String {
        // This would use the GlobalLingo framework
        // For now, return fallback
        return fallback
    }
}

struct LocalizationExample_Previews: PreviewProvider {
    static var previews: some View {
        LocalizationExample()
    }
} 
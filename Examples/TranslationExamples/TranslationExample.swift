import SwiftUI
import GlobalLingo

struct TranslationExample: View {
    @State private var sourceText = "Hello world"
    @State private var targetLanguage = "es"
    @State private var translatedText = ""
    @State private var isTranslating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Translation Examples")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Translation Input
            VStack(spacing: 15) {
                Text("Translation Input")
                    .font(.headline)
                
                TextField("Enter text to translate", text: $sourceText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Picker("Target Language", selection: $targetLanguage) {
                    Text("Spanish").tag("es")
                    Text("French").tag("fr")
                    Text("German").tag("de")
                    Text("Italian").tag("it")
                    Text("Portuguese").tag("pt")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Button("Translate") {
                    translateText()
                }
                .buttonStyle(.borderedProminent)
                .disabled(sourceText.isEmpty || isTranslating)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            // Translation Result
            VStack(spacing: 15) {
                Text("Translation Result")
                    .font(.headline)
                
                if isTranslating {
                    ProgressView("Translating...")
                        .progressViewStyle(.circular)
                } else if !translatedText.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Original:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(sourceText)
                            .font(.body)
                        
                        Divider()
                        
                        Text("Translated:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(translatedText)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            // Batch Translation
            VStack(spacing: 15) {
                Text("Batch Translation")
                    .font(.headline)
                
                Button("Translate Common Phrases") {
                    translateBatch()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            Spacer()
        }
        .padding()
    }
    
    private func translateText() {
        isTranslating = true
        
        // Simulate translation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // This would use the GlobalLingo translation framework
            switch targetLanguage {
            case "es":
                translatedText = "Hola mundo"
            case "fr":
                translatedText = "Bonjour le monde"
            case "de":
                translatedText = "Hallo Welt"
            case "it":
                translatedText = "Ciao mondo"
            case "pt":
                translatedText = "Olá mundo"
            default:
                translatedText = sourceText
            }
            isTranslating = false
        }
    }
    
    private func translateBatch() {
        let phrases = [
            "Welcome to our app",
            "Thank you for using our service",
            "Please rate our app",
            "Settings",
            "Help"
        ]
        
        // This would use batch translation
        print("Batch translation would be performed here")
    }
}

struct TranslationExample_Previews: PreviewProvider {
    static var previews: some View {
        TranslationExample()
    }
} 
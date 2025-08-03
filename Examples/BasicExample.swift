import SwiftUI
import GlobalLingo

struct BasicExampleView: View {
    @StateObject private var translationEngine = TranslationEngine()
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var sourceLanguage: Language = .english
    @State private var targetLanguage: Language = .spanish
    @State private var isTranslating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "globe")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("GlobalLingo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Professional Multi-Language Translation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Language Selection
                HStack(spacing: 20) {
                    LanguagePickerView(
                        title: "From",
                        selectedLanguage: $sourceLanguage
                    )
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.blue)
                    
                    LanguagePickerView(
                        title: "To",
                        selectedLanguage: $targetLanguage
                    )
                }
                .padding(.horizontal)
                
                // Input Area
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter text to translate")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $inputText)
                        .frame(height: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Translate Button
                Button(action: translateText) {
                    HStack {
                        if isTranslating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        
                        Text(isTranslating ? "Translating..." : "Translate")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(inputText.isEmpty || isTranslating)
                .padding(.horizontal)
                
                // Translation Result
                if !translatedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Translation")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(translatedText)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .alert("Translation Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            setupTranslationEngine()
        }
    }
    
    private func setupTranslationEngine() {
        translationEngine.configure(
            defaultSourceLanguage: .english,
            defaultTargetLanguage: .spanish,
            enableOfflineMode: true,
            enableCaching: true,
            cacheSize: 1000
        )
    }
    
    private func translateText() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError(message: "Please enter some text to translate")
            return
        }
        
        isTranslating = true
        
        Task {
            do {
                let result = try await translationEngine.translate(
                    text: inputText,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                
                await MainActor.run {
                    translatedText = result
                    isTranslating = false
                }
            } catch {
                await MainActor.run {
                    showError(message: "Translation failed: \(error.localizedDescription)")
                    isTranslating = false
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct LanguagePickerView: View {
    let title: String
    @Binding var selectedLanguage: Language
    
    private let languages: [Language] = [
        .english, .spanish, .french, .german, .italian,
        .portuguese, .russian, .chinese, .japanese, .korean
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Menu {
                ForEach(languages, id: \.self) { language in
                    Button(language.name) {
                        selectedLanguage = language
                    }
                }
            } label: {
                HStack {
                    Text(selectedLanguage.name)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    BasicExampleView()
} 
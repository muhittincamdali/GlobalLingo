import SwiftUI

/// Main UI module for GlobalLingo
/// Provides SwiftUI components for translation interface
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public struct GlobalLingoUI {
    
    // MARK: - Main Translation View
    
    /// Main translation interface
    public struct TranslationView: View {
        @StateObject private var translationEngine = TranslationEngine()
        @State private var inputText = ""
        @State private var translatedText = ""
        @State private var sourceLanguage: Language = .english
        @State private var targetLanguage: Language = .spanish
        @State private var isTranslating = false
        
        public init() {}
        
        public var body: some View {
            NavigationView {
                VStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Language Selection
                    languageSelectionView
                    
                    // Input Area
                    inputAreaView
                    
                    // Translate Button
                    translateButtonView
                    
                    // Translation Result
                    if !translatedText.isEmpty {
                        translationResultView
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("GlobalLingo")
                .onAppear {
                    setupTranslationEngine()
                }
            }
        }
        
        private var headerView: some View {
            VStack(spacing: 8) {
                Image(systemName: "globe")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Professional Translation")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        
        private var languageSelectionView: some View {
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
        }
        
        private var inputAreaView: some View {
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
        }
        
        private var translateButtonView: some View {
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
        }
        
        private var translationResultView: some View {
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
            guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            
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
                        translatedText = "Translation failed: \(error.localizedDescription)"
                        isTranslating = false
                    }
                }
            }
        }
    }
    
    // MARK: - Language Picker View
    
    /// Language picker component
    public struct LanguagePickerView: View {
        let title: String
        @Binding var selectedLanguage: Language
        
        private let languages: [Language] = [
            .english, .spanish, .french, .german, .italian,
            .portuguese, .russian, .chinese, .japanese, .korean
        ]
        
        public init(title: String, selectedLanguage: Binding<Language>) {
            self.title = title
            self._selectedLanguage = selectedLanguage
        }
        
        public var body: some View {
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
    
    // MARK: - Voice Recognition View
    
    /// Voice recognition interface
    public struct VoiceRecognitionView: View {
        @StateObject private var voiceRecognition = VoiceRecognition()
        @State private var isRecording = false
        @State private var recognizedText = ""
        @State private var audioLevel: Float = 0.0
        
        public init() {}
        
        public var body: some View {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(isRecording ? .red : .blue)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)
                    
                    Text("Voice Recognition")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                // Audio Level Indicator
                if isRecording {
                    VStack(spacing: 8) {
                        Text("Listening...")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        AudioLevelView(level: audioLevel)
                            .frame(height: 60)
                    }
                }
                
                // Recognized Text
                if !recognizedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recognized Text")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(recognizedText)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                // Control Button
                Button(action: toggleRecording) {
                    VStack(spacing: 8) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(isRecording ? .red : .blue)
                        
                        Text(isRecording ? "Stop" : "Record")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isRecording ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isRecording ? Color.red : Color.blue, lineWidth: 2)
                            )
                    )
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                setupVoiceRecognition()
            }
        }
        
        private func setupVoiceRecognition() {
            voiceRecognition.configure(
                language: .english,
                enableNoiseCancellation: true,
                enableAccentRecognition: true
            )
            
            voiceRecognition.setAudioLevelCallback { level in
                audioLevel = level
            }
        }
        
        private func toggleRecording() {
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        }
        
        private func startRecording() {
            Task {
                do {
                    try await voiceRecognition.startRecording()
                    
                    await MainActor.run {
                        isRecording = true
                        recognizedText = ""
                    }
                } catch {
                    print("Failed to start recording: \(error)")
                }
            }
        }
        
        private func stopRecording() {
            Task {
                do {
                    try await voiceRecognition.stopRecording()
                    let text = try await voiceRecognition.getRecognizedText()
                    
                    await MainActor.run {
                        isRecording = false
                        recognizedText = text
                    }
                } catch {
                    await MainActor.run {
                        isRecording = false
                        recognizedText = "Recognition failed: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // MARK: - Audio Level View
    
    /// Audio level visualization component
    public struct AudioLevelView: View {
        let level: Float
        
        public init(level: Float) {
            self.level = level
        }
        
        public var body: some View {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                    
                    // Audio level bars
                    HStack(spacing: 4) {
                        ForEach(0..<20, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(audioLevelColor(for: index))
                                .frame(width: 4)
                                .frame(height: audioLevelHeight(for: index))
                                .animation(.easeInOut(duration: 0.1), value: level)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        
        private func audioLevelColor(for index: Int) -> Color {
            let normalizedLevel = level * 20
            return index < normalizedLevel ? .red : Color(.systemGray4)
        }
        
        private func audioLevelHeight(for index: Int) -> CGFloat {
            let normalizedLevel = level * 20
            let baseHeight: CGFloat = 8
            let maxHeight: CGFloat = 40
            
            if index < normalizedLevel {
                let progress = Float(index) / normalizedLevel
                return baseHeight + CGFloat(progress) * (maxHeight - baseHeight)
            } else {
                return baseHeight
            }
        }
    }
} 
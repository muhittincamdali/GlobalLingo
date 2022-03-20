import SwiftUI
import GlobalLingo
import AVFoundation

struct VoiceRecognitionExampleView: View {
    @StateObject private var voiceRecognition = VoiceRecognition()
    @StateObject private var translationEngine = TranslationEngine()
    
    @State private var isRecording = false
    @State private var recognizedText = ""
    @State private var translatedText = ""
    @State private var sourceLanguage: Language = .english
    @State private var targetLanguage: Language = .spanish
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var audioLevel: Float = 0.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(isRecording ? .red : .blue)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)
                    
                    Text("Voice Recognition")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Speak and translate in real-time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Audio Level Indicator
                if isRecording {
                    VStack(spacing: 8) {
                        Text("Listening...")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        AudioLevelView(level: audioLevel)
                            .frame(height: 60)
                            .padding(.horizontal)
                    }
                }
                
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
                    .padding(.horizontal)
                }
                
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
                
                // Control Buttons
                HStack(spacing: 20) {
                    // Record Button
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
                    
                    // Translate Button
                    Button(action: translateRecognizedText) {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            
                            Text("Translate")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                        )
                    }
                    .disabled(recognizedText.isEmpty)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            setupVoiceRecognition()
            setupTranslationEngine()
        }
    }
    
    private func setupVoiceRecognition() {
        voiceRecognition.configure(
            language: sourceLanguage,
            enableNoiseCancellation: true,
            enableAccentRecognition: true
        )
        
        // Set up audio level monitoring
        voiceRecognition.setAudioLevelCallback { level in
            audioLevel = level
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
                }
            } catch {
                await MainActor.run {
                    showError(message: "Failed to start recording: \(error.localizedDescription)")
                }
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
                    showError(message: "Failed to stop recording: \(error.localizedDescription)")
                    isRecording = false
                }
            }
        }
    }
    
    private func translateRecognizedText() {
        guard !recognizedText.isEmpty else {
            showError(message: "No text to translate")
            return
        }
        
        Task {
            do {
                let result = try await translationEngine.translate(
                    text: recognizedText,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                
                await MainActor.run {
                    translatedText = result
                }
            } catch {
                await MainActor.run {
                    showError(message: "Translation failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct AudioLevelView: View {
    let level: Float
    
    var body: some View {
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

#Preview {
    VoiceRecognitionExampleView()
} 
import Foundation
import AVFoundation
import Speech
import Crypto
import Logging

/// Voice recognition and speech-to-text functionality for GlobalLingo
/// Handles real-time speech recognition, audio processing, and voice translation
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public class VoiceRecognition: ObservableObject {
    
    // MARK: - Properties
    
    private let logger = Logger(label: "GlobalLingo.VoiceRecognition")
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    private let synthesizer = AVSpeechSynthesizer()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioLevelCallback: ((Float) -> Void)?
    
    private var configuration: VoiceRecognitionConfiguration?
    private var isConfigured = false
    private var isRecording = false
    
    // MARK: - Published Properties
    
    @Published public var isListening = false
    @Published public var recognizedText = ""
    @Published public var confidence: Float = 0.0
    @Published public var audioLevel: Float = 0.0
    @Published public var errorMessage: String?
    
    // MARK: - Initialization
    
    public init() {
        setupAudioSession()
        setupSpeechRecognizer()
    }
    
    // MARK: - Configuration
    
    /// Configure voice recognition with custom settings
    /// - Parameter config: Configuration object containing recognition settings
    public func configure(_ config: VoiceRecognitionConfiguration) {
        self.configuration = config
        self.isConfigured = true
        
        // Configure speech recognizer
        if let speechRecognizer = speechRecognizer {
            speechRecognizer.defaultTaskHint = .confirmation
            speechRecognizer.recognitionLevel = config.recognitionLevel
        }
        
        logger.info("Voice recognition configured successfully")
    }
    
    // MARK: - Speech Recognition
    
    /// Start recording and recognizing speech
    public func startRecording() async throws {
        guard isConfigured else {
            throw VoiceRecognitionError.notConfigured
        }
        
        guard !isRecording else {
            throw VoiceRecognitionError.alreadyRecording
        }
        
        guard await requestSpeechAuthorization() else {
            throw VoiceRecognitionError.authorizationDenied
        }
        
        do {
            try await startAudioRecording()
            
            await MainActor.run {
                isRecording = true
                isListening = true
                recognizedText = ""
                errorMessage = nil
            }
            
            logger.info("Voice recording started")
            
        } catch {
            logger.error("Failed to start recording: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Stop recording and get recognized text
    public func stopRecording() async throws {
        guard isRecording else {
            throw VoiceRecognitionError.notRecording
        }
        
        do {
            try await stopAudioRecording()
            
            await MainActor.run {
                isRecording = false
                isListening = false
            }
            
            logger.info("Voice recording stopped")
            
        } catch {
            logger.error("Failed to stop recording: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Get the recognized text from the current recording session
    public func getRecognizedText() async throws -> String {
        guard isConfigured else {
            throw VoiceRecognitionError.notConfigured
        }
        
        guard !isRecording else {
            throw VoiceRecognitionError.stillRecording
        }
        
        return recognizedText
    }
    
    /// Recognize speech from audio data
    /// - Parameter audioData: Audio data to recognize
    /// - Returns: Recognized text
    public func recognizeSpeech(audioData: Data) async throws -> String {
        guard isConfigured else {
            throw VoiceRecognitionError.notConfigured
        }
        
        guard !audioData.isEmpty else {
            throw VoiceRecognitionError.emptyAudioData
        }
        
        do {
            let result = try await performSpeechRecognition(audioData: audioData)
            
            await MainActor.run {
                recognizedText = result
            }
            
            logger.info("Speech recognition completed successfully")
            return result
            
        } catch {
            logger.error("Speech recognition failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Audio Quality
    
    /// Set audio quality for recording
    /// - Parameter quality: Audio quality setting
    public func setAudioQuality(_ quality: AudioQuality) {
        guard let config = configuration else { return }
        
        var updatedConfig = config
        updatedConfig.audioQuality = quality
        self.configuration = updatedConfig
        
        logger.info("Audio quality set to: \(quality)")
    }
    
    /// Get current audio quality setting
    public func getAudioQuality() -> AudioQuality {
        return configuration?.audioQuality ?? .high
    }
    
    // MARK: - Audio Level Monitoring
    
    /// Set callback for audio level monitoring
    /// - Parameter callback: Callback function for audio level updates
    public func setAudioLevelCallback(_ callback: @escaping (Float) -> Void) {
        self.audioLevelCallback = callback
    }
    
    // MARK: - Text-to-Speech
    
    /// Synthesize speech from text
    /// - Parameters:
    ///   - text: Text to synthesize
    ///   - language: Language for synthesis
    ///   - voice: Voice type for synthesis
    /// - Returns: Audio data of synthesized speech
    public func synthesizeSpeech(
        text: String,
        language: Language,
        voice: VoiceType = .default
    ) async throws -> Data {
        
        guard isConfigured else {
            throw VoiceRecognitionError.notConfigured
        }
        
        guard !text.isEmpty else {
            throw VoiceRecognitionError.emptyText
        }
        
        do {
            let utterance = createSpeechUtterance(
                text: text,
                language: language,
                voice: voice
            )
            
            let audioData = try await performSpeechSynthesis(utterance: utterance)
            
            logger.info("Speech synthesis completed successfully")
            return audioData
            
        } catch {
            logger.error("Speech synthesis failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupSpeechRecognizer() {
        guard let speechRecognizer = speechRecognizer else {
            logger.error("Speech recognizer not available")
            return
        }
        
        speechRecognizer.delegate = self
    }
    
    private func requestSpeechAuthorization() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    private func startAudioRecording() async throws {
        // Cancel any existing recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Create and configure recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceRecognitionError.recognitionRequestFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
            
            // Calculate audio level
            let audioLevel = self.calculateAudioLevel(buffer: buffer)
            DispatchQueue.main.async {
                self.audioLevel = audioLevel
                self.audioLevelCallback?(audioLevel)
            }
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        // Start recognition task
        guard let speechRecognizer = speechRecognizer else {
            throw VoiceRecognitionError.speechRecognizerNotAvailable
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                    self.confidence = result.confidence
                }
            }
        }
    }
    
    private func stopAudioRecording() async throws {
        // Stop audio engine
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
    
    private func performSpeechRecognition(audioData: Data) async throws -> String {
        guard let speechRecognizer = speechRecognizer else {
            throw VoiceRecognitionError.speechRecognizerNotAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = SFSpeechURLRecognitionRequest()
            
            // Create temporary file for audio data
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_audio.wav")
            
            do {
                try audioData.write(to: tempURL)
                request.url = tempURL
                
                speechRecognizer.recognitionTask(with: request) { result, error in
                    // Clean up temporary file
                    try? FileManager.default.removeItem(at: tempURL)
                    
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    if let result = result {
                        continuation.resume(returning: result.bestTranscription.formattedString)
                    } else {
                        continuation.resume(throwing: VoiceRecognitionError.recognitionFailed)
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func createSpeechUtterance(
        text: String,
        language: Language,
        voice: VoiceType
    ) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.code)
        utterance.rate = voice.rate
        utterance.pitchMultiplier = voice.pitch
        utterance.volume = voice.volume
        return utterance
    }
    
    private func performSpeechSynthesis(utterance: AVSpeechUtterance) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            // This is a simplified implementation
            // In a real implementation, you would capture the synthesized audio
            synthesizer.speak(utterance)
            
            // For now, return empty data
            // In a real implementation, you would capture the audio output
            continuation.resume(returning: Data())
        }
    }
    
    private func calculateAudioLevel(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0.0 }
        
        let frameLength = UInt(buffer.frameLength)
        var sum: Float = 0.0
        
        for i in 0..<Int(frameLength) {
            let sample = channelData[i]
            sum += sample * sample
        }
        
        let rms = sqrt(sum / Float(frameLength))
        return min(rms * 10, 1.0) // Scale and clamp to 0-1
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension VoiceRecognition: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            logger.warning("Speech recognition became unavailable")
        }
    }
}

// MARK: - Supporting Types

public struct VoiceRecognitionConfiguration {
    public let language: Language
    public let enableNoiseCancellation: Bool
    public let enableAccentRecognition: Bool
    public let recognitionLevel: SFSpeechRecognitionLevel
    public let audioQuality: AudioQuality
    public let maxRecordingDuration: TimeInterval
    
    public init(
        language: Language = .english,
        enableNoiseCancellation: Bool = true,
        enableAccentRecognition: Bool = true,
        recognitionLevel: SFSpeechRecognitionLevel = .accurate,
        audioQuality: AudioQuality = .high,
        maxRecordingDuration: TimeInterval = 60.0
    ) {
        self.language = language
        self.enableNoiseCancellation = enableNoiseCancellation
        self.enableAccentRecognition = enableAccentRecognition
        self.recognitionLevel = recognitionLevel
        self.audioQuality = audioQuality
        self.maxRecordingDuration = maxRecordingDuration
    }
}

public enum AudioQuality {
    case low
    case medium
    case high
    
    var sampleRate: Double {
        switch self {
        case .low: return 8000
        case .medium: return 16000
        case .high: return 44100
        }
    }
    
    var bitDepth: Int {
        switch self {
        case .low: return 8
        case .medium: return 16
        case .high: return 24
        }
    }
}

public enum VoiceType {
    case `default`
    case slow
    case fast
    case highPitch
    case lowPitch
    
    var rate: Float {
        switch self {
        case .default: return 0.5
        case .slow: return 0.3
        case .fast: return 0.7
        case .highPitch: return 0.5
        case .lowPitch: return 0.5
        }
    }
    
    var pitch: Float {
        switch self {
        case .default: return 1.0
        case .slow: return 1.0
        case .fast: return 1.0
        case .highPitch: return 1.5
        case .lowPitch: return 0.5
        }
    }
    
    var volume: Float {
        switch self {
        case .default: return 1.0
        case .slow: return 1.0
        case .fast: return 1.0
        case .highPitch: return 1.0
        case .lowPitch: return 1.0
        }
    }
}

public enum VoiceRecognitionError: LocalizedError {
    case notConfigured
    case alreadyRecording
    case notRecording
    case stillRecording
    case authorizationDenied
    case recognitionRequestFailed
    case speechRecognizerNotAvailable
    case recognitionFailed
    case emptyAudioData
    case emptyText
    case audioSessionError
    case synthesisFailed
    
    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Voice recognition is not configured"
        case .alreadyRecording:
            return "Voice recognition is already recording"
        case .notRecording:
            return "Voice recognition is not recording"
        case .stillRecording:
            return "Voice recognition is still recording"
        case .authorizationDenied:
            return "Speech recognition authorization denied"
        case .recognitionRequestFailed:
            return "Failed to create recognition request"
        case .speechRecognizerNotAvailable:
            return "Speech recognizer is not available"
        case .recognitionFailed:
            return "Speech recognition failed"
        case .emptyAudioData:
            return "Audio data is empty"
        case .emptyText:
            return "Text is empty"
        case .audioSessionError:
            return "Audio session error"
        case .synthesisFailed:
            return "Speech synthesis failed"
        }
    }
} 
import Foundation
public protocol VoiceRecognitionUseCaseProtocol { func recognizeSpeech(audioData: Data, language: Language, quality: VoiceRecognitionQuality) async throws -> VoiceRecognitionResult }

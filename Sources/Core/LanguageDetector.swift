import Foundation
import NaturalLanguage

/// Language detector for GlobalLingo translation framework
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public class LanguageDetector {
    
    private let recognizer = NLLanguageRecognizer()
    
    public init() {
        setupRecognizer()
    }
    
    public func detectLanguage(text: String) async throws -> Language {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LanguageDetectionError.emptyText
        }
        
        recognizer.reset()
        recognizer.processString(text)
        
        guard let detectedLanguage = recognizer.dominantLanguage else {
            throw LanguageDetectionError.detectionFailed
        }
        
        guard let language = convertNLLanguageToLanguage(detectedLanguage) else {
            throw LanguageDetectionError.unsupportedLanguage
        }
        
        return language
    }
    
    private func setupRecognizer() {
        recognizer.reset()
        recognizer.processString("")
    }
    
    private func convertNLLanguageToLanguage(_ nlLanguage: NLLanguage) -> Language? {
        switch nlLanguage {
        case .english: return .english
        case .spanish: return .spanish
        case .french: return .french
        case .german: return .german
        case .italian: return .italian
        case .portuguese: return .portuguese
        case .russian: return .russian
        case .chinese: return .chinese
        case .japanese: return .japanese
        case .korean: return .korean
        case .arabic: return .arabic
        case .hindi: return .hindi
        case .turkish: return .turkish
        case .dutch: return .dutch
        case .polish: return .polish
        case .swedish: return .swedish
        case .norwegian: return .norwegian
        case .danish: return .danish
        case .finnish: return .finnish
        case .greek: return .greek
        case .hebrew: return .hebrew
        case .thai: return .thai
        case .vietnamese: return .vietnamese
        case .indonesian: return .indonesian
        default: return nil
        }
    }
}

public enum LanguageDetectionError: LocalizedError {
    case emptyText
    case detectionFailed
    case unsupportedLanguage
    
    public var errorDescription: String? {
        switch self {
        case .emptyText: return "Text is empty"
        case .detectionFailed: return "Language detection failed"
        case .unsupportedLanguage: return "Detected language is not supported"
        }
    }
} 
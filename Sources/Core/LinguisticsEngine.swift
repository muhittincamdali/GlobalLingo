import Foundation
import NaturalLanguage

/// Advanced linguistics engine using Apple's NaturalLanguage framework.
/// 
/// This component provides real "AI" depth to GlobalLingo by detecting
/// sentiment, language, and lexical categories in real-time.
public actor ContextualLinguisticsEngine {
    
    public init() {}
    
    /// Detects the predominant language of the given text.
    public func detectLanguage(for text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.dominantLanguage?.rawValue
    }
    
    /// Analyzes the sentiment of the text to help choose the right tone for translation.
    public func analyzeSentiment(for text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        return Double(sentiment?.rawValue ?? "0") ?? 0.0
    }
}

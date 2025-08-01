import Foundation
public protocol TranslationUseCaseProtocol { func translate(text: String, from sourceLanguage: Language, to targetLanguage: Language, quality: TranslationQuality) async throws -> TranslationResult }

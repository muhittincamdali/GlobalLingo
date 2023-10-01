import Foundation
public protocol OfflineTranslationUseCaseProtocol { func translateOffline(text: String, from sourceLanguage: Language, to targetLanguage: Language, quality: TranslationQuality) async throws -> TranslationResult }

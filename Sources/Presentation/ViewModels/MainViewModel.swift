import Foundation
import SwiftUI
import Combine

/// Main view model for the GlobalLingo app
@MainActor
public class MainViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var currentLanguage: Language = Language.findByCode("en") ?? Language.commonLanguages[0]
    @Published public var targetLanguage: Language = Language.findByCode("es") ?? Language.commonLanguages[1]
    @Published public var inputText: String = ""
    @Published public var translatedText: String = ""
    @Published public var isTranslating: Bool = false
    @Published public var translationError: String?
    @Published public var isPremiumUser: Bool = false
    @Published public var availableLanguages: [Language] = []
    @Published public var recentTranslations: [TranslationResult] = []
    @Published public var favoriteTranslations: [TranslationResult] = []
    @Published public var isLoading: Bool = false
    @Published public var showError: Bool = false
    @Published public var errorMessage: String = ""
    
    // MARK: - Dependencies
    
    private let translationUseCase: TranslationUseCaseProtocol
    private let voiceRecognitionUseCase: VoiceRecognitionUseCaseProtocol
    private let premiumFeaturesUseCase: PremiumFeaturesUseCaseProtocol
    private let offlineTranslationUseCase: OfflineTranslationUseCaseProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let storageManager: StorageManagerProtocol
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var translationTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    /// Initialize the main view model
    /// - Parameters:
    ///   - translationUseCase: Translation use case
    ///   - voiceRecognitionUseCase: Voice recognition use case
    ///   - premiumFeaturesUseCase: Premium features use case
    ///   - offlineTranslationUseCase: Offline translation use case
    ///   - analyticsService: Analytics service
    ///   - storageManager: Storage manager
    public init(
        translationUseCase: TranslationUseCaseProtocol,
        voiceRecognitionUseCase: VoiceRecognitionUseCaseProtocol,
        premiumFeaturesUseCase: PremiumFeaturesUseCaseProtocol,
        offlineTranslationUseCase: OfflineTranslationUseCaseProtocol,
        analyticsService: AnalyticsServiceProtocol,
        storageManager: StorageManagerProtocol
    ) {
        self.translationUseCase = translationUseCase
        self.voiceRecognitionUseCase = voiceRecognitionUseCase
        self.premiumFeaturesUseCase = premiumFeaturesUseCase
        self.offlineTranslationUseCase = offlineTranslationUseCase
        self.analyticsService = analyticsService
        self.storageManager = storageManager
        
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Public Methods
    
    /// Translate the input text
    public func translate() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError(message: "Please enter text to translate")
            return
        }
        
        isTranslating = true
        translationError = nil
        
        // Cancel any existing translation task
        translationTask?.cancel()
        
        translationTask = Task {
            do {
                let result = try await translationUseCase.translate(
                    text: inputText,
                    from: currentLanguage,
                    to: targetLanguage,
                    quality: .high
                )
                
                if !Task.isCancelled {
                    await MainActor.run {
                        self.translatedText = result.translatedText
                        self.addToRecentTranslations(result)
                        self.analyticsService.trackEvent(.translationCompleted, properties: [
                            "source_language": self.currentLanguage.code,
                            "target_language": self.targetLanguage.code,
                            "text_length": self.inputText.count
                        ])
                    }
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.translationError = error.localizedDescription
                        self.showError(message: error.localizedDescription)
                        self.analyticsService.trackEvent(.translationFailed, properties: [
                            "error": error.localizedDescription
                        ])
                    }
                }
            }
            
            if !Task.isCancelled {
                await MainActor.run {
                    self.isTranslating = false
                }
            }
        }
    }
    
    /// Swap source and target languages
    public func swapLanguages() {
        let temp = currentLanguage
        currentLanguage = targetLanguage
        targetLanguage = temp
        
        // Swap texts if both are filled
        if !inputText.isEmpty && !translatedText.isEmpty {
            let tempText = inputText
            inputText = translatedText
            translatedText = tempText
        }
        
        analyticsService.trackEvent(.languagesSwapped, properties: [
            "new_source": currentLanguage.code,
            "new_target": targetLanguage.code
        ])
    }
    
    /// Clear input and output text
    public func clearText() {
        inputText = ""
        translatedText = ""
        translationError = nil
        
        analyticsService.trackEvent(.textCleared)
    }
    
    /// Add translation to favorites
    /// - Parameter translation: Translation to add
    public func addToFavorites(_ translation: TranslationResult) {
        if !favoriteTranslations.contains(where: { $0.originalText == translation.originalText }) {
            favoriteTranslations.append(translation)
            saveFavorites()
            
            analyticsService.trackEvent(.translationFavorited, properties: [
                "source_language": translation.sourceLanguage.code,
                "target_language": translation.targetLanguage.code
            ])
        }
    }
    
    /// Remove translation from favorites
    /// - Parameter translation: Translation to remove
    public func removeFromFavorites(_ translation: TranslationResult) {
        favoriteTranslations.removeAll { $0.originalText == translation.originalText }
        saveFavorites()
        
        analyticsService.trackEvent(.translationUnfavorited)
    }
    
    /// Check if translation is in favorites
    /// - Parameter translation: Translation to check
    /// - Returns: True if in favorites
    public func isInFavorites(_ translation: TranslationResult) -> Bool {
        return favoriteTranslations.contains { $0.originalText == translation.originalText }
    }
    
    /// Load recent translations
    public func loadRecentTranslations() {
        Task {
            let recent = await storageManager.getRecentTranslations()
            await MainActor.run {
                self.recentTranslations = recent
            }
        }
    }
    
    /// Load favorite translations
    public func loadFavoriteTranslations() {
        Task {
            let favorites = await storageManager.getFavoriteTranslations()
            await MainActor.run {
                self.favoriteTranslations = favorites
            }
        }
    }
    
    /// Check premium status
    public func checkPremiumStatus() {
        Task {
            let isPremium = await premiumFeaturesUseCase.isPremiumUser()
            await MainActor.run {
                self.isPremiumUser = isPremium
            }
        }
    }
    
    /// Show error message
    /// - Parameter message: Error message to show
    public func showError(message: String) {
        errorMessage = message
        showError = true
        
        // Auto-hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showError = false
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Auto-translate when input text changes (with debounce)
        $inputText
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self, !text.isEmpty else { return }
                self.translate()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        isLoading = true
        
        Task {
            // Load available languages
            await MainActor.run {
                self.availableLanguages = Language.commonLanguages
            }
            
            // Load recent and favorite translations
            loadRecentTranslations()
            loadFavoriteTranslations()
            
            // Check premium status
            checkPremiumStatus()
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func addToRecentTranslations(_ translation: TranslationResult) {
        // Remove if already exists
        recentTranslations.removeAll { $0.originalText == translation.originalText }
        
        // Add to beginning
        recentTranslations.insert(translation, at: 0)
        
        // Keep only last 50 translations
        if recentTranslations.count > 50 {
            recentTranslations = Array(recentTranslations.prefix(50))
        }
        
        // Save to storage
        Task {
            await storageManager.saveRecentTranslations(recentTranslations)
        }
    }
    
    private func saveFavorites() {
        Task {
            await storageManager.saveFavoriteTranslations(favoriteTranslations)
        }
    }
}

// MARK: - Analytics Events

/// Analytics events for tracking
public enum AnalyticsEvent {
    case translationCompleted
    case translationFailed
    case languagesSwapped
    case textCleared
    case translationFavorited
    case translationUnfavorited
    
    public var name: String {
        switch self {
        case .translationCompleted:
            return "translation_completed"
        case .translationFailed:
            return "translation_failed"
        case .languagesSwapped:
            return "languages_swapped"
        case .textCleared:
            return "text_cleared"
        case .translationFavorited:
            return "translation_favorited"
        case .translationUnfavorited:
            return "translation_unfavorited"
        }
    }
}

// MARK: - Analytics Service Protocol

/// Protocol for analytics service operations
public protocol AnalyticsServiceProtocol {
    
    /// Track an analytics event
    /// - Parameters:
    ///   - event: Event to track
    ///   - properties: Event properties
    func trackEvent(_ event: AnalyticsEvent, properties: [String: Any]?)
    
    /// Track an analytics event without properties
    /// - Parameter event: Event to track
    func trackEvent(_ event: AnalyticsEvent)
}

// MARK: - Storage Manager Protocol Extension

/// Extension for storage manager with translation-specific methods
public extension StorageManagerProtocol {
    
    /// Get recent translations
    /// - Returns: Array of recent translations
    func getRecentTranslations() async -> [TranslationResult] {
        // Implementation would depend on actual storage mechanism
        return []
    }
    
    /// Save recent translations
    /// - Parameter translations: Translations to save
    func saveRecentTranslations(_ translations: [TranslationResult]) async {
        // Implementation would depend on actual storage mechanism
    }
    
    /// Get favorite translations
    /// - Returns: Array of favorite translations
    func getFavoriteTranslations() async -> [TranslationResult] {
        // Implementation would depend on actual storage mechanism
        return []
    }
    
    /// Save favorite translations
    /// - Parameter translations: Translations to save
    func saveFavoriteTranslations(_ translations: [TranslationResult]) async {
        // Implementation would depend on actual storage mechanism
    }
}

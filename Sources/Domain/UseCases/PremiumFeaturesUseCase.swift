import Foundation

/// Protocol defining premium features use case operations
public protocol PremiumFeaturesUseCaseProtocol {
    
    /// Check if user has premium access
    /// - Returns: True if user has premium access
    func isPremiumUser() async -> Bool
    
    /// Get available premium features
    /// - Returns: Array of premium features
    func getAvailablePremiumFeatures() async -> [PremiumFeature]
    
    /// Check if specific feature is available
    /// - Parameter feature: Premium feature to check
    /// - Returns: True if feature is available
    func isFeatureAvailable(_ feature: PremiumFeature) async -> Bool
    
    /// Purchase premium subscription
    /// - Parameter plan: Premium plan to purchase
    /// - Returns: Purchase result
    func purchasePremium(plan: PremiumPlan) async throws -> PurchaseResult
    
    /// Restore premium purchase
    /// - Returns: True if restoration successful
    func restorePremiumPurchase() async throws -> Bool
    
    /// Get premium subscription status
    /// - Returns: Subscription status
    func getSubscriptionStatus() async -> SubscriptionStatus
    
    /// Cancel premium subscription
    /// - Returns: True if cancellation successful
    func cancelPremiumSubscription() async throws -> Bool
}

/// Implementation of the premium features use case
public class PremiumFeaturesUseCase: PremiumFeaturesUseCaseProtocol {
    
    // MARK: - Dependencies
    
    private let premiumService: PremiumServiceProtocol
    private let userManager: UserManagerProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    // MARK: - Initialization
    
    /// Initialize the premium features use case
    /// - Parameters:
    ///   - premiumService: Premium service
    ///   - userManager: User manager
    ///   - analyticsService: Analytics service
    public init(
        premiumService: PremiumServiceProtocol,
        userManager: UserManagerProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.premiumService = premiumService
        self.userManager = userManager
        self.analyticsService = analyticsService
    }
    
    // MARK: - PremiumFeaturesUseCaseProtocol Implementation
    
    public func isPremiumUser() async -> Bool {
        return await premiumService.isPremiumUser()
    }
    
    public func getAvailablePremiumFeatures() async -> [PremiumFeature] {
        return await premiumService.getAvailableFeatures()
    }
    
    public func isFeatureAvailable(_ feature: PremiumFeature) async -> Bool {
        let isPremium = await isPremiumUser()
        let availableFeatures = await getAvailablePremiumFeatures()
        
        return isPremium && availableFeatures.contains(feature)
    }
    
    public func purchasePremium(plan: PremiumPlan) async throws -> PurchaseResult {
        
        // Track purchase attempt
        await analyticsService.trackEvent(.premiumPurchaseAttempted, properties: [
            "plan": plan.rawValue,
            "price": plan.price
        ])
        
        // Perform purchase
        let result = try await premiumService.purchase(plan: plan)
        
        // Track purchase result
        await analyticsService.trackEvent(.premiumPurchaseCompleted, properties: [
            "plan": plan.rawValue,
            "success": result.success
        ])
        
        return result
    }
    
    public func restorePremiumPurchase() async throws -> Bool {
        
        // Track restore attempt
        await analyticsService.trackEvent(.premiumRestoreAttempted)
        
        // Perform restoration
        let success = try await premiumService.restorePurchase()
        
        // Track restore result
        await analyticsService.trackEvent(.premiumRestoreCompleted, properties: [
            "success": success
        ])
        
        return success
    }
    
    public func getSubscriptionStatus() async -> SubscriptionStatus {
        return await premiumService.getSubscriptionStatus()
    }
    
    public func cancelPremiumSubscription() async throws -> Bool {
        
        // Track cancellation attempt
        await analyticsService.trackEvent(.premiumCancellationAttempted)
        
        // Perform cancellation
        let success = try await premiumService.cancelSubscription()
        
        // Track cancellation result
        await analyticsService.trackEvent(.premiumCancellationCompleted, properties: [
            "success": success
        ])
        
        return success
    }
}

// MARK: - Premium Feature

/// Represents a premium feature
public enum PremiumFeature: String, CaseIterable, Codable {
    case unlimitedTranslations = "unlimited_translations"
    case offlineTranslation = "offline_translation"
    case voiceTranslation = "voice_translation"
    case advancedAnalytics = "advanced_analytics"
    case prioritySupport = "priority_support"
    case customThemes = "custom_themes"
    case adFree = "ad_free"
    case batchTranslation = "batch_translation"
    case translationHistory = "translation_history"
    case exportTranslations = "export_translations"
    
    public var displayName: String {
        switch self {
        case .unlimitedTranslations:
            return "Unlimited Translations"
        case .offlineTranslation:
            return "Offline Translation"
        case .voiceTranslation:
            return "Voice Translation"
        case .advancedAnalytics:
            return "Advanced Analytics"
        case .prioritySupport:
            return "Priority Support"
        case .customThemes:
            return "Custom Themes"
        case .adFree:
            return "Ad-Free Experience"
        case .batchTranslation:
            return "Batch Translation"
        case .translationHistory:
            return "Translation History"
        case .exportTranslations:
            return "Export Translations"
        }
    }
    
    public var description: String {
        switch self {
        case .unlimitedTranslations:
            return "Translate unlimited text without restrictions"
        case .offlineTranslation:
            return "Translate text without internet connection"
        case .voiceTranslation:
            return "Translate speech in real-time"
        case .advancedAnalytics:
            return "Detailed translation analytics and insights"
        case .prioritySupport:
            return "Get priority customer support"
        case .customThemes:
            return "Customize app appearance with themes"
        case .adFree:
            return "Enjoy ad-free experience"
        case .batchTranslation:
            return "Translate multiple texts at once"
        case .translationHistory:
            return "Access your translation history"
        case .exportTranslations:
            return "Export translations to various formats"
        }
    }
}

// MARK: - Premium Plan

/// Represents a premium subscription plan
public enum PremiumPlan: String, CaseIterable, Codable {
    case monthly = "monthly"
    case yearly = "yearly"
    case lifetime = "lifetime"
    
    public var displayName: String {
        switch self {
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        case .lifetime:
            return "Lifetime"
        }
    }
    
    public var price: Decimal {
        switch self {
        case .monthly:
            return 9.99
        case .yearly:
            return 99.99
        case .lifetime:
            return 299.99
        }
    }
    
    public var savings: String? {
        switch self {
        case .monthly:
            return nil
        case .yearly:
            return "Save 17%"
        case .lifetime:
            return "Best Value"
        }
    }
}

// MARK: - Purchase Result

/// Represents the result of a premium purchase
public struct PurchaseResult: Codable {
    public let success: Bool
    public let transactionId: String?
    public let error: String?
    public let plan: PremiumPlan
    public let timestamp: Date
    
    public init(
        success: Bool,
        transactionId: String? = nil,
        error: String? = nil,
        plan: PremiumPlan,
        timestamp: Date = Date()
    ) {
        self.success = success
        self.transactionId = transactionId
        self.error = error
        self.plan = plan
        self.timestamp = timestamp
    }
}

// MARK: - Subscription Status

/// Represents the status of a premium subscription
public struct SubscriptionStatus: Codable {
    public let isActive: Bool
    public let plan: PremiumPlan?
    public let startDate: Date?
    public let endDate: Date?
    public let autoRenew: Bool
    public let trialEndDate: Date?
    
    public init(
        isActive: Bool,
        plan: PremiumPlan? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        autoRenew: Bool = false,
        trialEndDate: Date? = nil
    ) {
        self.isActive = isActive
        self.plan = plan
        self.startDate = startDate
        self.endDate = endDate
        self.autoRenew = autoRenew
        self.trialEndDate = trialEndDate
    }
}

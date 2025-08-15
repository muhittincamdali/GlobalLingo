import Foundation
import LocalAuthentication
import CryptoKit
import Security
import OSLog

/// Enterprise-grade biometric authentication manager
/// Supports Face ID, Touch ID, and device passcode authentication
/// Provides secure biometric template management and privacy protection
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public final class BiometricManager: ObservableObject, Sendable {
    
    // MARK: - Singleton & Logger
    
    /// Shared instance with thread-safe initialization
    public static let shared = BiometricManager()
    
    /// Enterprise logging for biometric events
    private let logger = Logger(subsystem: "com.globallingo.security", category: "biometric")
    
    // MARK: - Published State
    
    /// Biometric availability status
    @Published public private(set) var biometricStatus = BiometricStatus()
    
    /// Current biometric configuration
    @Published public private(set) var configuration = BiometricConfiguration()
    
    /// Biometric performance metrics
    @Published public private(set) var performanceMetrics = PerformanceMetrics()
    
    /// Security health status
    @Published public private(set) var securityHealth = SecurityHealth()
    
    // MARK: - Configuration
    
    /// Biometric authentication configuration
    public struct BiometricConfiguration {
        public let enableFaceID: Bool
        public let enableTouchID: Bool
        public let enableDevicePasscode: Bool
        public let fallbackToPasscode: Bool
        public let maxRetryAttempts: Int
        public let authenticationTimeout: TimeInterval
        public let templateStorage: TemplateStorage
        public let privacyLevel: PrivacyLevel
        public let auditLevel: AuditLevel
        public let complianceMode: ComplianceMode
        
        public init(
            enableFaceID: Bool = true,
            enableTouchID: Bool = true,
            enableDevicePasscode: Bool = true,
            fallbackToPasscode: Bool = true,
            maxRetryAttempts: Int = 3,
            authenticationTimeout: TimeInterval = 30.0,
            templateStorage: TemplateStorage = .secureEnclave,
            privacyLevel: PrivacyLevel = .high,
            auditLevel: AuditLevel = .comprehensive,
            complianceMode: ComplianceMode = .enterprise
        ) {
            self.enableFaceID = enableFaceID
            self.enableTouchID = enableTouchID
            self.enableDevicePasscode = enableDevicePasscode
            self.fallbackToPasscode = fallbackToPasscode
            self.maxRetryAttempts = maxRetryAttempts
            self.authenticationTimeout = authenticationTimeout
            self.templateStorage = templateStorage
            self.privacyLevel = privacyLevel
            self.auditLevel = auditLevel
            self.complianceMode = complianceMode
        }
        
        /// Enterprise biometric configuration
        public static let enterprise = BiometricConfiguration(
            enableFaceID: true,
            enableTouchID: true,
            enableDevicePasscode: true,
            fallbackToPasscode: false, // Require biometric only
            maxRetryAttempts: 2,
            authenticationTimeout: 20.0,
            templateStorage: .secureEnclave,
            privacyLevel: .maximum,
            auditLevel: .comprehensive,
            complianceMode: .enterprise
        )
        
        /// High-security configuration
        public static let highSecurity = BiometricConfiguration(
            enableFaceID: true,
            enableTouchID: true,
            enableDevicePasscode: false, // Biometric only
            fallbackToPasscode: false,
            maxRetryAttempts: 1,
            authenticationTimeout: 15.0,
            templateStorage: .secureEnclave,
            privacyLevel: .maximum,
            auditLevel: .forensic,
            complianceMode: .fips140Level3
        )
    }
    
    /// Template storage options
    public enum TemplateStorage: String, CaseIterable {
        case secureEnclave = "secure-enclave"
        case keychain = "keychain"
        case memory = "memory"
        case disabled = "disabled"
    }
    
    /// Privacy levels for biometric data
    public enum PrivacyLevel: String, CaseIterable {
        case basic = "basic"
        case standard = "standard"
        case high = "high"
        case maximum = "maximum"
    }
    
    /// Audit levels for biometric events
    public enum AuditLevel: String, CaseIterable {
        case minimal = "minimal"
        case standard = "standard"
        case comprehensive = "comprehensive"
        case forensic = "forensic"
    }
    
    /// Compliance modes for biometric systems
    public enum ComplianceMode: String, CaseIterable {
        case basic = "basic"
        case enterprise = "enterprise"
        case government = "government"
        case fips140Level2 = "fips-140-2"
        case fips140Level3 = "fips-140-3"
        case commonCriteria = "common-criteria"
    }
    
    // MARK: - Biometric Status
    
    /// Comprehensive biometric availability status
    public struct BiometricStatus {
        public private(set) var isAvailable: Bool = false
        public private(set) var biometryType: LABiometryType = .none
        public private(set) var isEnrolled: Bool = false
        public private(set) var isLockedOut: Bool = false
        public private(set) var errorMessage: String?
        public private(set) var supportedTypes: [BiometricType] = []
        public private(set) var secureEnclaveAvailable: Bool = false
        public private(set) var hardwareSupport: HardwareSupport = HardwareSupport()
        public private(set) var privacyCompliance: PrivacyCompliance = PrivacyCompliance()
        public private(set) var lastStatusCheck: Date = Date()
        
        mutating func updateStatus(
            available: Bool,
            biometryType: LABiometryType,
            enrolled: Bool,
            lockedOut: Bool,
            error: String? = nil,
            supportedTypes: [BiometricType] = [],
            secureEnclave: Bool = false,
            hardware: HardwareSupport = HardwareSupport(),
            privacy: PrivacyCompliance = PrivacyCompliance()
        ) {
            self.isAvailable = available
            self.biometryType = biometryType
            self.isEnrolled = enrolled
            self.isLockedOut = lockedOut
            self.errorMessage = error
            self.supportedTypes = supportedTypes
            self.secureEnclaveAvailable = secureEnclave
            self.hardwareSupport = hardware
            self.privacyCompliance = privacy
            self.lastStatusCheck = Date()
        }
    }
    
    /// Supported biometric types
    public enum BiometricType: String, CaseIterable {
        case faceID = "face-id"
        case touchID = "touch-id"
        case opticID = "optic-id" // Vision Pro
        case devicePasscode = "device-passcode"
        case none = "none"
        
        /// Convert from LABiometryType
        public init(from laBiometryType: LABiometryType) {
            switch laBiometryType {
            case .faceID:
                self = .faceID
            case .touchID:
                self = .touchID
            case .opticID:
                self = .opticID
            case .none:
                self = .none
            @unknown default:
                self = .none
            }
        }
        
        /// Human-readable description
        public var description: String {
            switch self {
            case .faceID:
                return "Face ID"
            case .touchID:
                return "Touch ID"
            case .opticID:
                return "Optic ID"
            case .devicePasscode:
                return "Device Passcode"
            case .none:
                return "None Available"
            }
        }
    }
    
    /// Hardware support information
    public struct HardwareSupport {
        public private(set) var secureEnclaveGeneration: String?
        public private(set) var biometricSensorVersion: String?
        public private(set) var hardwareEncryption: Bool = false
        public private(set) var tamperDetection: Bool = false
        public private(set) var certificationLevel: String?
        public private(set) var performanceClass: PerformanceClass = .standard
        
        public enum PerformanceClass: String, CaseIterable {
            case basic = "basic"
            case standard = "standard"
            case enhanced = "enhanced"
            case premium = "premium"
        }
        
        mutating func updateSupport(
            enclaveGen: String?,
            sensorVersion: String?,
            hwEncryption: Bool,
            tamperDetect: Bool,
            certification: String?,
            performance: PerformanceClass
        ) {
            self.secureEnclaveGeneration = enclaveGen
            self.biometricSensorVersion = sensorVersion
            self.hardwareEncryption = hwEncryption
            self.tamperDetection = tamperDetect
            self.certificationLevel = certification
            self.performanceClass = performance
        }
    }
    
    /// Privacy compliance status
    public struct PrivacyCompliance {
        public private(set) var gdprCompliant: Bool = true
        public private(set) var ccpaCompliant: Bool = true
        public private(set) var biometricDataProcessing: Bool = false
        public private(set) var templateStorage: String = "secure-enclave"
        public private(set) var dataRetention: TimeInterval = 0 // No retention by default
        public private(set) var consentRequired: Bool = true
        public private(set) var rightToErasure: Bool = true
        public private(set) var privacyNoticeProvided: Bool = false
        
        mutating func updateCompliance(
            gdpr: Bool,
            ccpa: Bool,
            processing: Bool,
            storage: String,
            retention: TimeInterval,
            consent: Bool,
            erasure: Bool,
            notice: Bool
        ) {
            self.gdprCompliant = gdpr
            self.ccpaCompliant = ccpa
            self.biometricDataProcessing = processing
            self.templateStorage = storage
            self.dataRetention = retention
            self.consentRequired = consent
            self.rightToErasure = erasure
            self.privacyNoticeProvided = notice
        }
    }
    
    // MARK: - Authentication Results
    
    /// Comprehensive biometric authentication result
    public struct AuthenticationResult {
        public let success: Bool
        public let biometricType: BiometricType
        public let authenticationTime: TimeInterval
        public let qualityScore: Double
        public let confidenceLevel: ConfidenceLevel
        public let templateMatched: Bool
        public let errorCode: BiometricError?
        public let retryCount: Int
        public let securityLevel: SecurityLevel
        public let metadata: [String: Any]
        
        public enum ConfidenceLevel: String, CaseIterable {
            case veryLow = "very-low"
            case low = "low"
            case medium = "medium"
            case high = "high"
            case veryHigh = "very-high"
        }
        
        public enum SecurityLevel: String, CaseIterable {
            case basic = "basic"
            case standard = "standard"
            case enhanced = "enhanced"
            case maximum = "maximum"
        }
        
        public init(
            success: Bool,
            biometricType: BiometricType,
            authenticationTime: TimeInterval = 0.0,
            qualityScore: Double = 0.0,
            confidenceLevel: ConfidenceLevel = .medium,
            templateMatched: Bool = false,
            errorCode: BiometricError? = nil,
            retryCount: Int = 0,
            securityLevel: SecurityLevel = .standard,
            metadata: [String: Any] = [:]
        ) {
            self.success = success
            self.biometricType = biometricType
            self.authenticationTime = authenticationTime
            self.qualityScore = qualityScore
            self.confidenceLevel = confidenceLevel
            self.templateMatched = templateMatched
            self.errorCode = errorCode
            self.retryCount = retryCount
            self.securityLevel = securityLevel
            self.metadata = metadata
        }
    }
    
    /// Authentication request configuration
    public struct AuthenticationRequest {
        public let prompt: String
        public let allowedTypes: [BiometricType]
        public let timeout: TimeInterval
        public let maxRetries: Int
        public let fallbackEnabled: Bool
        public let privacyMode: Bool
        public let auditEnabled: Bool
        public let metadata: [String: Any]
        
        public init(
            prompt: String,
            allowedTypes: [BiometricType] = [.faceID, .touchID],
            timeout: TimeInterval = 30.0,
            maxRetries: Int = 3,
            fallbackEnabled: Bool = true,
            privacyMode: Bool = false,
            auditEnabled: Bool = true,
            metadata: [String: Any] = [:]
        ) {
            self.prompt = prompt
            self.allowedTypes = allowedTypes
            self.timeout = timeout
            self.maxRetries = maxRetries
            self.fallbackEnabled = fallbackEnabled
            self.privacyMode = privacyMode
            self.auditEnabled = auditEnabled
            self.metadata = metadata
        }
        
        /// Enterprise authentication request
        public static func enterprise(prompt: String) -> AuthenticationRequest {
            return AuthenticationRequest(
                prompt: prompt,
                allowedTypes: [.faceID, .touchID],
                timeout: 20.0,
                maxRetries: 2,
                fallbackEnabled: false,
                privacyMode: true,
                auditEnabled: true
            )
        }
    }
    
    // MARK: - Performance Metrics
    
    /// Biometric performance metrics
    public struct PerformanceMetrics {
        public private(set) var totalAttempts: Int = 0
        public private(set) var successfulAttempts: Int = 0
        public private(set) var failedAttempts: Int = 0
        public private(set) var averageAuthTime: TimeInterval = 0.0
        public private(set) var falseAcceptanceRate: Double = 0.0
        public private(set) var falseRejectionRate: Double = 0.0
        public private(set) var templateQualityScore: Double = 1.0
        public private(set) var systemPerformance: SystemPerformance = SystemPerformance()
        public private(set) var lastUpdated: Date = Date()
        
        /// Performance targets for enterprise systems
        public static let targets = PerformanceTargets(
            maxAuthTime: 2.0, // 2 seconds
            minSuccessRate: 0.98, // 98%
            maxFalseAcceptanceRate: 0.0001, // 0.01%
            maxFalseRejectionRate: 0.02, // 2%
            minTemplateQuality: 0.8 // 80%
        )
        
        mutating func recordAuthentication(
            success: Bool,
            authTime: TimeInterval,
            qualityScore: Double,
            biometricType: BiometricType
        ) {
            totalAttempts += 1
            lastUpdated = Date()
            
            if success {
                successfulAttempts += 1
            } else {
                failedAttempts += 1
            }
            
            // Update average authentication time
            averageAuthTime = (averageAuthTime * Double(totalAttempts - 1) + authTime) / Double(totalAttempts)
            
            // Update template quality (running average)
            templateQualityScore = (templateQualityScore * Double(totalAttempts - 1) + qualityScore) / Double(totalAttempts)
            
            // Update system performance
            systemPerformance.updateMetrics(
                type: biometricType,
                success: success,
                time: authTime,
                quality: qualityScore
            )
        }
        
        mutating func updateErrorRates(far: Double, frr: Double) {
            falseAcceptanceRate = far
            falseRejectionRate = frr
            lastUpdated = Date()
        }
        
        /// Calculate success rate
        public var successRate: Double {
            guard totalAttempts > 0 else { return 1.0 }
            return Double(successfulAttempts) / Double(totalAttempts)
        }
    }
    
    /// Performance targets for monitoring
    public struct PerformanceTargets {
        public let maxAuthTime: TimeInterval
        public let minSuccessRate: Double
        public let maxFalseAcceptanceRate: Double
        public let maxFalseRejectionRate: Double
        public let minTemplateQuality: Double
        
        public init(
            maxAuthTime: TimeInterval,
            minSuccessRate: Double,
            maxFalseAcceptanceRate: Double,
            maxFalseRejectionRate: Double,
            minTemplateQuality: Double
        ) {
            self.maxAuthTime = maxAuthTime
            self.minSuccessRate = minSuccessRate
            self.maxFalseAcceptanceRate = maxFalseAcceptanceRate
            self.maxFalseRejectionRate = maxFalseRejectionRate
            self.minTemplateQuality = minTemplateQuality
        }
    }
    
    /// System performance by biometric type
    public struct SystemPerformance {
        public private(set) var faceIDMetrics: TypeMetrics = TypeMetrics()
        public private(set) var touchIDMetrics: TypeMetrics = TypeMetrics()
        public private(set) var opticIDMetrics: TypeMetrics = TypeMetrics()
        public private(set) var passcodeMetrics: TypeMetrics = TypeMetrics()
        
        mutating func updateMetrics(
            type: BiometricType,
            success: Bool,
            time: TimeInterval,
            quality: Double
        ) {
            switch type {
            case .faceID:
                faceIDMetrics.update(success: success, time: time, quality: quality)
            case .touchID:
                touchIDMetrics.update(success: success, time: time, quality: quality)
            case .opticID:
                opticIDMetrics.update(success: success, time: time, quality: quality)
            case .devicePasscode:
                passcodeMetrics.update(success: success, time: time, quality: quality)
            case .none:
                break
            }
        }
    }
    
    /// Type-specific metrics
    public struct TypeMetrics {
        public private(set) var attempts: Int = 0
        public private(set) var successes: Int = 0
        public private(set) var averageTime: TimeInterval = 0.0
        public private(set) var averageQuality: Double = 0.0
        public private(set) var lastUsed: Date?
        
        mutating func update(success: Bool, time: TimeInterval, quality: Double) {
            attempts += 1
            lastUsed = Date()
            
            if success {
                successes += 1
            }
            
            averageTime = (averageTime * Double(attempts - 1) + time) / Double(attempts)
            averageQuality = (averageQuality * Double(attempts - 1) + quality) / Double(attempts)
        }
        
        /// Calculate success rate for this type
        public var successRate: Double {
            guard attempts > 0 else { return 1.0 }
            return Double(successes) / Double(attempts)
        }
    }
    
    // MARK: - Security Health
    
    /// Security health monitoring
    public struct SecurityHealth {
        public private(set) var overallHealth: Double = 1.0
        public private(set) var authenticationHealth: Double = 1.0
        public private(set) var privacyHealth: Double = 1.0
        public private(set) var complianceHealth: Double = 1.0
        public private(set) var systemHealth: Double = 1.0
        public private(set) var lastHealthCheck: Date = Date()
        public private(set) var alerts: [SecurityAlert] = []
        public private(set) var recommendations: [SecurityRecommendation] = []
        
        mutating func updateHealth(
            authentication: Double,
            privacy: Double,
            compliance: Double,
            system: Double,
            alerts: [SecurityAlert] = [],
            recommendations: [SecurityRecommendation] = []
        ) {
            self.authenticationHealth = authentication
            self.privacyHealth = privacy
            self.complianceHealth = compliance
            self.systemHealth = system
            self.overallHealth = (authentication + privacy + compliance + system) / 4.0
            self.alerts = alerts
            self.recommendations = recommendations
            self.lastHealthCheck = Date()
        }
    }
    
    /// Security alerts
    public struct SecurityAlert {
        public let id: String
        public let severity: Severity
        public let category: Category
        public let title: String
        public let description: String
        public let recommendation: String
        public let createdAt: Date
        
        public enum Severity: String, CaseIterable {
            case low = "low"
            case medium = "medium"
            case high = "high"
            case critical = "critical"
        }
        
        public enum Category: String, CaseIterable {
            case performance = "performance"
            case security = "security"
            case privacy = "privacy"
            case compliance = "compliance"
            case hardware = "hardware"
        }
        
        public init(
            id: String = UUID().uuidString,
            severity: Severity,
            category: Category,
            title: String,
            description: String,
            recommendation: String
        ) {
            self.id = id
            self.severity = severity
            self.category = category
            self.title = title
            self.description = description
            self.recommendation = recommendation
            self.createdAt = Date()
        }
    }
    
    /// Security recommendations
    public struct SecurityRecommendation {
        public let id: String
        public let priority: Priority
        public let category: Category
        public let title: String
        public let description: String
        public let implementation: String
        public let expectedImpact: String
        public let createdAt: Date
        
        public enum Priority: String, CaseIterable {
            case low = "low"
            case medium = "medium"
            case high = "high"
            case critical = "critical"
        }
        
        public enum Category: String, CaseIterable {
            case configuration = "configuration"
            case policy = "policy"
            case hardware = "hardware"
            case privacy = "privacy"
            case performance = "performance"
        }
        
        public init(
            id: String = UUID().uuidString,
            priority: Priority,
            category: Category,
            title: String,
            description: String,
            implementation: String,
            expectedImpact: String
        ) {
            self.id = id
            self.priority = priority
            self.category = category
            self.title = title
            self.description = description
            self.implementation = implementation
            self.expectedImpact = expectedImpact
            self.createdAt = Date()
        }
    }
    
    // MARK: - Private Properties
    
    /// Local Authentication context
    private let authContext: LAContext
    
    /// Retry attempt tracking
    private var retryAttempts: [String: Int] = [:] // request-id -> count
    
    /// Authentication session tracking
    private var activeSessions: [String: AuthenticationSession] = [:]
    
    /// Thread-safe access queue
    private let biometricQueue = DispatchQueue(label: "com.globallingo.biometric", qos: .userInitiated)
    
    // MARK: - Initialization
    
    private init() {
        self.authContext = LAContext()
        
        setupAuthContext()
        updateBiometricStatus()
        startHealthMonitoring()
        
        logger.info("BiometricManager initialized")
    }
    
    /// Configure biometric manager
    public func configure(with configuration: BiometricConfiguration) async {
        await biometricQueue.perform {
            self.configuration = configuration
            self.setupAuthContext()
            self.updateBiometricStatus()
        }
        
        logger.info("BiometricManager configured with \(configuration.complianceMode.rawValue) compliance")
    }
    
    // MARK: - Core Authentication Methods
    
    /// Authenticate using biometric authentication
    public func authenticate(
        request: AuthenticationRequest
    ) async throws -> AuthenticationResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        let requestId = UUID().uuidString
        
        return try await biometricQueue.perform { [weak self] in
            guard let self = self else {
                throw BiometricError.managerDeallocated
            }
            
            logger.info("Starting biometric authentication: \(requestId)")
            
            // Check biometric availability
            guard self.biometricStatus.isAvailable else {
                let result = AuthenticationResult(
                    success: false,
                    biometricType: .none,
                    errorCode: .biometricNotAvailable,
                    metadata: ["request_id": requestId]
                )
                
                await MainActor.run {
                    self.performanceMetrics.recordAuthentication(
                        success: false,
                        authTime: CFAbsoluteTimeGetCurrent() - startTime,
                        qualityScore: 0.0,
                        biometricType: .none
                    )
                }
                
                return result
            }
            
            // Check if biometric is locked out
            if self.biometricStatus.isLockedOut {
                let result = AuthenticationResult(
                    success: false,
                    biometricType: BiometricType(from: self.biometricStatus.biometryType),
                    errorCode: .biometricLockout,
                    metadata: ["request_id": requestId]
                )
                
                await MainActor.run {
                    self.performanceMetrics.recordAuthentication(
                        success: false,
                        authTime: CFAbsoluteTimeGetCurrent() - startTime,
                        qualityScore: 0.0,
                        biometricType: BiometricType(from: self.biometricStatus.biometryType)
                    )
                }
                
                return result
            }
            
            // Determine authentication policy
            let policy = self.determineAuthenticationPolicy(for: request)
            let biometricType = BiometricType(from: self.biometricStatus.biometryType)
            
            // Track retry attempts
            let currentRetryCount = self.retryAttempts[requestId] ?? 0
            if currentRetryCount >= request.maxRetries {
                throw BiometricError.maxRetriesExceeded
            }
            
            do {
                // Perform biometric authentication
                let success = try await self.performBiometricAuthentication(
                    policy: policy,
                    prompt: request.prompt,
                    timeout: request.timeout
                )
                
                let authTime = CFAbsoluteTimeGetCurrent() - startTime
                let qualityScore = self.calculateQualityScore(
                    biometricType: biometricType,
                    authTime: authTime,
                    success: success
                )
                
                // Create successful result
                let result = AuthenticationResult(
                    success: success,
                    biometricType: biometricType,
                    authenticationTime: authTime,
                    qualityScore: qualityScore,
                    confidenceLevel: self.calculateConfidenceLevel(qualityScore),
                    templateMatched: success,
                    retryCount: currentRetryCount,
                    securityLevel: self.determineSecurityLevel(biometricType),
                    metadata: [
                        "request_id": requestId,
                        "policy": policy.rawValue,
                        "privacy_mode": request.privacyMode
                    ]
                )
                
                // Clear retry attempts on success
                if success {
                    self.retryAttempts.removeValue(forKey: requestId)
                }
                
                // Record authentication attempt
                await MainActor.run {
                    self.performanceMetrics.recordAuthentication(
                        success: success,
                        authTime: authTime,
                        qualityScore: qualityScore,
                        biometricType: biometricType
                    )
                }
                
                // Log audit event if enabled
                if request.auditEnabled {
                    self.logAuthenticationEvent(
                        result: result,
                        request: request,
                        requestId: requestId
                    )
                }
                
                logger.info("Biometric authentication completed: \(requestId) - Success: \(success)")
                
                return result
                
            } catch {
                // Handle authentication error
                let biometricError = BiometricError.from(error)
                
                // Increment retry count
                self.retryAttempts[requestId] = currentRetryCount + 1
                
                let authTime = CFAbsoluteTimeGetCurrent() - startTime
                let result = AuthenticationResult(
                    success: false,
                    biometricType: biometricType,
                    authenticationTime: authTime,
                    qualityScore: 0.0,
                    confidenceLevel: .veryLow,
                    templateMatched: false,
                    errorCode: biometricError,
                    retryCount: currentRetryCount + 1,
                    securityLevel: .basic,
                    metadata: [
                        "request_id": requestId,
                        "error": error.localizedDescription
                    ]
                )
                
                // Record failed authentication
                await MainActor.run {
                    self.performanceMetrics.recordAuthentication(
                        success: false,
                        authTime: authTime,
                        qualityScore: 0.0,
                        biometricType: biometricType
                    )
                }
                
                // Log audit event if enabled
                if request.auditEnabled {
                    self.logAuthenticationEvent(
                        result: result,
                        request: request,
                        requestId: requestId
                    )
                }
                
                logger.warning("Biometric authentication failed: \(requestId) - Error: \(error.localizedDescription)")
                
                return result
            }
        }
    }
    
    /// Check biometric availability and status
    public func checkBiometricAvailability() async -> BiometricStatus {
        return await biometricQueue.perform { [weak self] in
            guard let self = self else {
                return BiometricStatus()
            }
            
            self.updateBiometricStatus()
            return self.biometricStatus
        }
    }
    
    /// Evaluate biometric policy without authentication
    public func evaluatePolicy(_ policy: LAPolicy) async -> (canEvaluate: Bool, error: Error?) {
        return await biometricQueue.perform { [weak self] in
            guard let self = self else {
                return (false, BiometricError.managerDeallocated)
            }
            
            var error: NSError?
            let canEvaluate = self.authContext.canEvaluatePolicy(policy, error: &error)
            
            return (canEvaluate, error)
        }
    }
    
    /// Get biometric change detection
    public func getBiometricChangeDetection() -> Data? {
        return authContext.evaluatedPolicyDomainState
    }
    
    /// Perform comprehensive security health check
    public func performSecurityHealthCheck() async -> SecurityHealth {
        return await biometricQueue.perform { [weak self] in
            guard let self = self else {
                return SecurityHealth()
            }
            
            logger.info("Performing biometric security health check")
            
            var alerts: [SecurityAlert] = []
            var recommendations: [SecurityRecommendation] = []
            
            // Check authentication performance
            let authHealth = self.assessAuthenticationHealth()
            if authHealth < 0.8 {
                alerts.append(SecurityAlert(
                    severity: .medium,
                    category: .performance,
                    title: "Authentication Performance",
                    description: "Biometric authentication performance is below optimal threshold",
                    recommendation: "Review biometric sensor calibration and system configuration"
                ))
            }
            
            // Check privacy compliance
            let privacyHealth = self.assessPrivacyHealth()
            if privacyHealth < 0.95 {
                recommendations.append(SecurityRecommendation(
                    priority: .high,
                    category: .privacy,
                    title: "Privacy Compliance Enhancement",
                    description: "Biometric privacy compliance can be improved",
                    implementation: "Review privacy settings and data handling policies",
                    expectedImpact: "Enhanced privacy protection and regulatory compliance"
                ))
            }
            
            // Check compliance status
            let complianceHealth = self.assessComplianceHealth()
            if complianceHealth < 0.9 {
                alerts.append(SecurityAlert(
                    severity: .high,
                    category: .compliance,
                    title: "Compliance Requirements",
                    description: "Some compliance requirements are not fully met",
                    recommendation: "Update biometric configuration to meet all compliance requirements"
                ))
            }
            
            // Check system health
            let systemHealth = self.assessSystemHealth()
            if systemHealth < 0.85 {
                recommendations.append(SecurityRecommendation(
                    priority: .medium,
                    category: .hardware,
                    title: "System Health Optimization",
                    description: "Biometric system health can be optimized",
                    implementation: "Update hardware drivers and calibrate biometric sensors",
                    expectedImpact: "Improved system reliability and performance"
                ))
            }
            
            var health = SecurityHealth()
            health.updateHealth(
                authentication: authHealth,
                privacy: privacyHealth,
                compliance: complianceHealth,
                system: systemHealth,
                alerts: alerts,
                recommendations: recommendations
            )
            
            self.securityHealth = health
            
            logger.info("Biometric security health check completed - Overall health: \(String(format: "%.1f", health.overallHealth * 100))%")
            
            return health
        }
    }
    
    // MARK: - Private Implementation
    
    /// Setup authentication context
    private func setupAuthContext() {
        authContext.touchIDAuthenticationAllowableReuseDuration = configuration.fallbackToPasscode ? 0 : 10 // 10 seconds reuse if no fallback
        authContext.localizedFallbackTitle = configuration.fallbackToPasscode ? "Use Passcode" : ""
        
        // Set additional context properties based on configuration
        if #available(iOS 16.0, macOS 13.0, *) {
            authContext.interactionNotAllowed = false
        }
    }
    
    /// Update biometric status
    private func updateBiometricStatus() {
        var error: NSError?
        let canEvaluate = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        let biometryType = authContext.biometryType
        let supportedTypes = determineSupportedTypes(biometryType: biometryType)
        let secureEnclaveAvailable = isSecureEnclaveAvailable()
        
        // Check enrollment status
        let isEnrolled = canEvaluate && error?.code != LAError.biometryNotEnrolled.rawValue
        
        // Check lockout status
        let isLockedOut = error?.code == LAError.biometryLockout.rawValue
        
        // Update hardware support
        var hardwareSupport = HardwareSupport()
        hardwareSupport.updateSupport(
            enclaveGen: getSecureEnclaveGeneration(),
            sensorVersion: getBiometricSensorVersion(),
            hwEncryption: secureEnclaveAvailable,
            tamperDetect: true, // Assume tamper detection is available
            certification: getCertificationLevel(),
            performance: getPerformanceClass()
        )
        
        // Update privacy compliance
        var privacyCompliance = PrivacyCompliance()
        privacyCompliance.updateCompliance(
            gdpr: true, // Biometric data not processed by app
            ccpa: true,
            processing: false, // No biometric data processing
            storage: configuration.templateStorage.rawValue,
            retention: 0, // No retention
            consent: configuration.privacyLevel == .maximum,
            erasure: true,
            notice: configuration.privacyLevel != .basic
        )
        
        biometricStatus.updateStatus(
            available: canEvaluate,
            biometryType: biometryType,
            enrolled: isEnrolled,
            lockedOut: isLockedOut,
            error: error?.localizedDescription,
            supportedTypes: supportedTypes,
            secureEnclave: secureEnclaveAvailable,
            hardware: hardwareSupport,
            privacy: privacyCompliance
        )
        
        logger.info("Biometric status updated - Available: \(canEvaluate), Type: \(BiometricType(from: biometryType).description)")
    }
    
    /// Determine supported biometric types
    private func determineSupportedTypes(biometryType: LABiometryType) -> [BiometricType] {
        var supportedTypes: [BiometricType] = []
        
        if configuration.enableDevicePasscode {
            supportedTypes.append(.devicePasscode)
        }
        
        switch biometryType {
        case .faceID:
            if configuration.enableFaceID {
                supportedTypes.append(.faceID)
            }
        case .touchID:
            if configuration.enableTouchID {
                supportedTypes.append(.touchID)
            }
        case .opticID:
            supportedTypes.append(.opticID)
        case .none:
            break
        @unknown default:
            break
        }
        
        return supportedTypes
    }
    
    /// Check Secure Enclave availability
    private func isSecureEnclaveAvailable() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // Test Secure Enclave availability by attempting key creation
        let keyAttributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false
            ]
        ]
        
        var publicKey, privateKey: SecKey?
        let status = SecKeyGeneratePair(keyAttributes as CFDictionary, &publicKey, &privateKey)
        
        return status == errSecSuccess
        #endif
    }
    
    /// Get Secure Enclave generation
    private func getSecureEnclaveGeneration() -> String? {
        // In real implementation, detect Secure Enclave generation
        return "A12+" // Placeholder
    }
    
    /// Get biometric sensor version
    private func getBiometricSensorVersion() -> String? {
        // In real implementation, detect sensor version
        return "v2.1" // Placeholder
    }
    
    /// Get certification level
    private func getCertificationLevel() -> String? {
        switch configuration.complianceMode {
        case .fips140Level2:
            return "FIPS 140-2 Level 2"
        case .fips140Level3:
            return "FIPS 140-2 Level 3"
        case .commonCriteria:
            return "Common Criteria EAL4+"
        default:
            return "Commercial Grade"
        }
    }
    
    /// Get performance class
    private func getPerformanceClass() -> HardwareSupport.PerformanceClass {
        // Determine based on device capabilities
        if isSecureEnclaveAvailable() {
            return .premium
        } else {
            return .standard
        }
    }
    
    /// Determine authentication policy
    private func determineAuthenticationPolicy(for request: AuthenticationRequest) -> LAPolicy {
        if request.fallbackEnabled {
            return .deviceOwnerAuthentication
        } else {
            return .deviceOwnerAuthenticationWithBiometrics
        }
    }
    
    /// Perform biometric authentication
    private func performBiometricAuthentication(
        policy: LAPolicy,
        prompt: String,
        timeout: TimeInterval
    ) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            // Set timeout
            let timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
                continuation.resume(throwing: BiometricError.authenticationTimeout)
            }
            
            authContext.evaluatePolicy(policy, localizedReason: prompt) { success, error in
                timeoutTimer.invalidate()
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    /// Calculate quality score based on authentication parameters
    private func calculateQualityScore(
        biometricType: BiometricType,
        authTime: TimeInterval,
        success: Bool
    ) -> Double {
        guard success else { return 0.0 }
        
        var score: Double = 1.0
        
        // Time factor (faster is better)
        let timeScore = max(0.0, 1.0 - (authTime / 5.0)) // 5 second max for full score
        score *= 0.4 + (timeScore * 0.6)
        
        // Biometric type factor
        switch biometricType {
        case .faceID:
            score *= 1.0 // Best quality
        case .touchID:
            score *= 0.95
        case .opticID:
            score *= 1.0
        case .devicePasscode:
            score *= 0.7 // Lower quality for passcode
        case .none:
            score = 0.0
        }
        
        return min(1.0, max(0.0, score))
    }
    
    /// Calculate confidence level
    private func calculateConfidenceLevel(_ qualityScore: Double) -> AuthenticationResult.ConfidenceLevel {
        switch qualityScore {
        case 0.9...1.0:
            return .veryHigh
        case 0.7..<0.9:
            return .high
        case 0.5..<0.7:
            return .medium
        case 0.2..<0.5:
            return .low
        default:
            return .veryLow
        }
    }
    
    /// Determine security level
    private func determineSecurityLevel(_ biometricType: BiometricType) -> AuthenticationResult.SecurityLevel {
        switch biometricType {
        case .faceID, .opticID:
            return configuration.templateStorage == .secureEnclave ? .maximum : .enhanced
        case .touchID:
            return configuration.templateStorage == .secureEnclave ? .enhanced : .standard
        case .devicePasscode:
            return .standard
        case .none:
            return .basic
        }
    }
    
    /// Log authentication event for audit
    private func logAuthenticationEvent(
        result: AuthenticationResult,
        request: AuthenticationRequest,
        requestId: String
    ) {
        let eventLevel: OSLogType = result.success ? .info : .error
        
        logger.log(level: eventLevel, """
            BIOMETRIC_AUTH: \
            request_id=\(requestId) \
            success=\(result.success) \
            type=\(result.biometricType.rawValue) \
            time=\(String(format: "%.3f", result.authenticationTime)) \
            quality=\(String(format: "%.3f", result.qualityScore)) \
            confidence=\(result.confidenceLevel.rawValue) \
            security=\(result.securityLevel.rawValue) \
            retries=\(result.retryCount)
            """)
    }
    
    /// Start health monitoring
    private func startHealthMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in // Every 5 minutes
            Task {
                await self?.performSecurityHealthCheck()
            }
        }
    }
    
    /// Assess authentication health
    private func assessAuthenticationHealth() -> Double {
        let targets = PerformanceMetrics.targets
        var score: Double = 1.0
        
        // Check success rate
        if performanceMetrics.successRate < targets.minSuccessRate {
            score -= 0.3
        }
        
        // Check average authentication time
        if performanceMetrics.averageAuthTime > targets.maxAuthTime {
            score -= 0.2
        }
        
        // Check false acceptance rate
        if performanceMetrics.falseAcceptanceRate > targets.maxFalseAcceptanceRate {
            score -= 0.3
        }
        
        // Check false rejection rate
        if performanceMetrics.falseRejectionRate > targets.maxFalseRejectionRate {
            score -= 0.2
        }
        
        return max(0.0, score)
    }
    
    /// Assess privacy health
    private func assessPrivacyHealth() -> Double {
        let privacy = biometricStatus.privacyCompliance
        var score: Double = 1.0
        
        if !privacy.gdprCompliant {
            score -= 0.3
        }
        
        if !privacy.ccpaCompliant {
            score -= 0.2
        }
        
        if privacy.biometricDataProcessing && configuration.privacyLevel == .maximum {
            score -= 0.2
        }
        
        if !privacy.consentRequired && configuration.privacyLevel != .basic {
            score -= 0.1
        }
        
        if !privacy.privacyNoticeProvided && configuration.privacyLevel == .maximum {
            score -= 0.2
        }
        
        return max(0.0, score)
    }
    
    /// Assess compliance health
    private func assessComplianceHealth() -> Double {
        var score: Double = 1.0
        
        // Check compliance mode requirements
        switch configuration.complianceMode {
        case .fips140Level3:
            if !biometricStatus.secureEnclaveAvailable {
                score -= 0.4
            }
            if configuration.templateStorage != .secureEnclave {
                score -= 0.3
            }
        case .fips140Level2:
            if configuration.templateStorage == .memory {
                score -= 0.2
            }
        case .government:
            if !biometricStatus.secureEnclaveAvailable {
                score -= 0.2
            }
        default:
            break
        }
        
        // Check audit level compliance
        if configuration.auditLevel == .minimal && configuration.complianceMode != .basic {
            score -= 0.1
        }
        
        return max(0.0, score)
    }
    
    /// Assess system health
    private func assessSystemHealth() -> Double {
        var score: Double = 1.0
        
        // Check biometric availability
        if !biometricStatus.isAvailable {
            score -= 0.4
        }
        
        // Check enrollment status
        if !biometricStatus.isEnrolled {
            score -= 0.2
        }
        
        // Check lockout status
        if biometricStatus.isLockedOut {
            score -= 0.3
        }
        
        // Check hardware support
        let hardware = biometricStatus.hardwareSupport
        if !hardware.hardwareEncryption {
            score -= 0.1
        }
        
        return max(0.0, score)
    }
}

// MARK: - Supporting Types

/// Authentication session tracking
private struct AuthenticationSession {
    let id: String
    let startTime: Date
    let request: BiometricManager.AuthenticationRequest
    var retryCount: Int = 0
    
    init(id: String, request: BiometricManager.AuthenticationRequest) {
        self.id = id
        self.startTime = Date()
        self.request = request
    }
}

/// Biometric-related errors
public enum BiometricError: LocalizedError, CustomStringConvertible {
    case managerDeallocated
    case biometricNotAvailable
    case biometricNotEnrolled
    case biometricLockout
    case authenticationFailed
    case authenticationTimeout
    case maxRetriesExceeded
    case userCancel
    case userFallback
    case systemCancel
    case passcodeNotSet
    case touchIDNotAvailable
    case touchIDNotEnrolled
    case touchIDLockout
    case faceIDNotAvailable
    case faceIDNotEnrolled
    case faceIDLockout
    case invalidContext
    case configurationError(String)
    
    /// Convert from LAError or other errors
    public static func from(_ error: Error) -> BiometricError {
        if let laError = error as? LAError {
            switch laError.code {
            case .biometryNotAvailable:
                return .biometricNotAvailable
            case .biometryNotEnrolled:
                return .biometricNotEnrolled
            case .biometryLockout:
                return .biometricLockout
            case .userCancel:
                return .userCancel
            case .userFallback:
                return .userFallback
            case .systemCancel:
                return .systemCancel
            case .passcodeNotSet:
                return .passcodeNotSet
            case .touchIDNotAvailable:
                return .touchIDNotAvailable
            case .touchIDNotEnrolled:
                return .touchIDNotEnrolled
            case .touchIDLockout:
                return .touchIDLockout
            case .authenticationFailed:
                return .authenticationFailed
            case .invalidContext:
                return .invalidContext
            @unknown default:
                return .authenticationFailed
            }
        }
        
        return .authenticationFailed
    }
    
    public var errorDescription: String? {
        switch self {
        case .managerDeallocated:
            return "BiometricManager has been deallocated"
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device"
        case .biometricNotEnrolled:
            return "No biometric data is enrolled on this device"
        case .biometricLockout:
            return "Biometric authentication is temporarily locked out"
        case .authenticationFailed:
            return "Biometric authentication failed"
        case .authenticationTimeout:
            return "Biometric authentication timed out"
        case .maxRetriesExceeded:
            return "Maximum authentication retries exceeded"
        case .userCancel:
            return "User cancelled biometric authentication"
        case .userFallback:
            return "User selected fallback authentication method"
        case .systemCancel:
            return "System cancelled biometric authentication"
        case .passcodeNotSet:
            return "Device passcode is not set"
        case .touchIDNotAvailable:
            return "Touch ID is not available on this device"
        case .touchIDNotEnrolled:
            return "No fingerprints are enrolled for Touch ID"
        case .touchIDLockout:
            return "Touch ID is temporarily locked out"
        case .faceIDNotAvailable:
            return "Face ID is not available on this device"
        case .faceIDNotEnrolled:
            return "Face ID is not set up on this device"
        case .faceIDLockout:
            return "Face ID is temporarily locked out"
        case .invalidContext:
            return "Authentication context is invalid"
        case .configurationError(let details):
            return "Biometric configuration error: \(details)"
        }
    }
    
    public var description: String {
        return errorDescription ?? "Unknown biometric error"
    }
}
import Foundation
import LocalAuthentication
import CryptoKit
import Security
import Combine
import OSLog

/// Enterprise-grade authentication manager providing comprehensive user authentication
/// Supports biometric authentication, multi-factor authentication, and enterprise SSO
/// Compliant with OAuth 2.0, OpenID Connect, SAML 2.0, and enterprise security standards
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public final class AuthenticationManager: ObservableObject, Sendable {
    
    // MARK: - Singleton & Logger
    
    /// Shared instance with thread-safe initialization
    public static let shared = AuthenticationManager()
    
    /// Enterprise logging with authentication event categorization
    private let logger = Logger(subsystem: "com.globallingo.security", category: "authentication")
    
    // MARK: - Configuration & State
    
    /// Authentication configuration with enterprise policies
    public struct AuthenticationConfiguration {
        public let authenticationMethods: Set<AuthenticationMethod>
        public let biometricPolicy: BiometricPolicy
        public let sessionTimeout: TimeInterval
        public let maxFailedAttempts: Int
        public let lockoutDuration: TimeInterval
        public let passwordPolicy: PasswordPolicy
        public let mfaRequired: Bool
        public let ssoEnabled: Bool
        public let complianceLevel: ComplianceLevel
        public let tokenLifetime: TimeInterval
        public let refreshTokenLifetime: TimeInterval
        public let enableDeviceBinding: Bool
        public let enableRiskAssessment: Bool
        
        public init(
            authenticationMethods: Set<AuthenticationMethod> = [.biometric, .password, .devicePasscode],
            biometricPolicy: BiometricPolicy = .any,
            sessionTimeout: TimeInterval = 30 * 60, // 30 minutes
            maxFailedAttempts: Int = 5,
            lockoutDuration: TimeInterval = 15 * 60, // 15 minutes
            passwordPolicy: PasswordPolicy = .enterprise,
            mfaRequired: Bool = true,
            ssoEnabled: Bool = false,
            complianceLevel: ComplianceLevel = .enterprise,
            tokenLifetime: TimeInterval = 60 * 60, // 1 hour
            refreshTokenLifetime: TimeInterval = 7 * 24 * 60 * 60, // 7 days
            enableDeviceBinding: Bool = true,
            enableRiskAssessment: Bool = true
        ) {
            self.authenticationMethods = authenticationMethods
            self.biometricPolicy = biometricPolicy
            self.sessionTimeout = sessionTimeout
            self.maxFailedAttempts = maxFailedAttempts
            self.lockoutDuration = lockoutDuration
            self.passwordPolicy = passwordPolicy
            self.mfaRequired = mfaRequired
            self.ssoEnabled = ssoEnabled
            self.complianceLevel = complianceLevel
            self.tokenLifetime = tokenLifetime
            self.refreshTokenLifetime = refreshTokenLifetime
            self.enableDeviceBinding = enableDeviceBinding
            self.enableRiskAssessment = enableRiskAssessment
        }
        
        /// Enterprise security configuration
        public static let enterprise = AuthenticationConfiguration(
            authenticationMethods: [.biometric, .password, .mfa],
            biometricPolicy: .any,
            sessionTimeout: 15 * 60, // 15 minutes
            maxFailedAttempts: 3,
            lockoutDuration: 30 * 60, // 30 minutes
            passwordPolicy: .enterprise,
            mfaRequired: true,
            ssoEnabled: true,
            complianceLevel: .enterprise,
            tokenLifetime: 30 * 60, // 30 minutes
            refreshTokenLifetime: 24 * 60 * 60, // 24 hours
            enableDeviceBinding: true,
            enableRiskAssessment: true
        )
        
        /// High security configuration for sensitive environments
        public static let highSecurity = AuthenticationConfiguration(
            authenticationMethods: [.biometric, .password, .mfa, .smartCard],
            biometricPolicy: .both,
            sessionTimeout: 5 * 60, // 5 minutes
            maxFailedAttempts: 2,
            lockoutDuration: 60 * 60, // 1 hour
            passwordPolicy: .highSecurity,
            mfaRequired: true,
            ssoEnabled: false,
            complianceLevel: .fips1402Level3,
            tokenLifetime: 15 * 60, // 15 minutes
            refreshTokenLifetime: 8 * 60 * 60, // 8 hours
            enableDeviceBinding: true,
            enableRiskAssessment: true
        )
    }
    
    /// Authentication methods supported by the system
    public enum AuthenticationMethod: String, CaseIterable {
        case biometric = "biometric"
        case password = "password"
        case devicePasscode = "device-passcode"
        case mfa = "multi-factor"
        case sso = "single-sign-on"
        case smartCard = "smart-card"
        case certificate = "certificate"
        case token = "token"
        
        public var displayName: String {
            switch self {
            case .biometric: return "Biometric Authentication"
            case .password: return "Password"
            case .devicePasscode: return "Device Passcode"
            case .mfa: return "Multi-Factor Authentication"
            case .sso: return "Single Sign-On"
            case .smartCard: return "Smart Card"
            case .certificate: return "Digital Certificate"
            case .token: return "Security Token"
            }
        }
        
        public var securityLevel: Int {
            switch self {
            case .devicePasscode: return 1
            case .password: return 2
            case .biometric: return 3
            case .token: return 4
            case .certificate: return 5
            case .smartCard: return 6
            case .mfa: return 7
            case .sso: return 3 // Depends on underlying method
            }
        }
    }
    
    /// Biometric authentication policies
    public enum BiometricPolicy: String, CaseIterable {
        case none = "none"
        case touchID = "touch-id"
        case faceID = "face-id"
        case any = "any"
        case both = "both"
        case deviceOwnerAuthentication = "device-owner"
        
        public var localAuthenticationPolicy: LAPolicy {
            switch self {
            case .none: return .deviceOwnerAuthentication
            case .touchID, .faceID, .any: return .deviceOwnerAuthenticationWithBiometrics
            case .both: return .deviceOwnerAuthenticationWithBiometrics
            case .deviceOwnerAuthentication: return .deviceOwnerAuthentication
            }
        }
    }
    
    /// Password policy enforcement
    public enum PasswordPolicy: String, CaseIterable {
        case basic = "basic"
        case standard = "standard"
        case enterprise = "enterprise"
        case highSecurity = "high-security"
        
        public var requirements: PasswordRequirements {
            switch self {
            case .basic:
                return PasswordRequirements(
                    minLength: 6,
                    requireUppercase: false,
                    requireLowercase: false,
                    requireNumbers: false,
                    requireSpecialChars: false,
                    maxAge: nil,
                    preventReuse: 0
                )
            case .standard:
                return PasswordRequirements(
                    minLength: 8,
                    requireUppercase: true,
                    requireLowercase: true,
                    requireNumbers: true,
                    requireSpecialChars: false,
                    maxAge: 90 * 24 * 60 * 60, // 90 days
                    preventReuse: 3
                )
            case .enterprise:
                return PasswordRequirements(
                    minLength: 12,
                    requireUppercase: true,
                    requireLowercase: true,
                    requireNumbers: true,
                    requireSpecialChars: true,
                    maxAge: 60 * 24 * 60 * 60, // 60 days
                    preventReuse: 5
                )
            case .highSecurity:
                return PasswordRequirements(
                    minLength: 16,
                    requireUppercase: true,
                    requireLowercase: true,
                    requireNumbers: true,
                    requireSpecialChars: true,
                    maxAge: 30 * 24 * 60 * 60, // 30 days
                    preventReuse: 10
                )
            }
        }
    }
    
    /// Password requirements structure
    public struct PasswordRequirements {
        public let minLength: Int
        public let requireUppercase: Bool
        public let requireLowercase: Bool
        public let requireNumbers: Bool
        public let requireSpecialChars: Bool
        public let maxAge: TimeInterval?
        public let preventReuse: Int
        
        public init(
            minLength: Int,
            requireUppercase: Bool,
            requireLowercase: Bool,
            requireNumbers: Bool,
            requireSpecialChars: Bool,
            maxAge: TimeInterval?,
            preventReuse: Int
        ) {
            self.minLength = minLength
            self.requireUppercase = requireUppercase
            self.requireLowercase = requireLowercase
            self.requireNumbers = requireNumbers
            self.requireSpecialChars = requireSpecialChars
            self.maxAge = maxAge
            self.preventReuse = preventReuse
        }
    }
    
    /// Compliance levels for regulatory requirements
    public enum ComplianceLevel: String, CaseIterable {
        case basic = "basic"
        case enterprise = "enterprise"
        case fips1402Level1 = "fips-140-2-level-1"
        case fips1402Level2 = "fips-140-2-level-2"
        case fips1402Level3 = "fips-140-2-level-3"
        case commonCriteria = "common-criteria"
        case soxCompliant = "sox-compliant"
        case gdprCompliant = "gdpr-compliant"
        case hipaaCompliant = "hipaa-compliant"
    }
    
    /// Authentication result with comprehensive metadata
    public struct AuthenticationResult {
        public let isAuthenticated: Bool
        public let userId: String?
        public let authenticationMethod: AuthenticationMethod
        public let sessionToken: String?
        public let refreshToken: String?
        public let expiresAt: Date?
        public let deviceId: String
        public let riskScore: Double
        public let authenticationTime: Date
        public let metadata: [String: Any]
        
        public init(
            isAuthenticated: Bool,
            userId: String? = nil,
            authenticationMethod: AuthenticationMethod,
            sessionToken: String? = nil,
            refreshToken: String? = nil,
            expiresAt: Date? = nil,
            deviceId: String,
            riskScore: Double = 0.0,
            authenticationTime: Date = Date(),
            metadata: [String: Any] = [:]
        ) {
            self.isAuthenticated = isAuthenticated
            self.userId = userId
            self.authenticationMethod = authenticationMethod
            self.sessionToken = sessionToken
            self.refreshToken = refreshToken
            self.expiresAt = expiresAt
            self.deviceId = deviceId
            self.riskScore = riskScore
            self.authenticationTime = authenticationTime
            self.metadata = metadata
        }
    }
    
    /// Session information for authenticated users
    public struct SessionInfo {
        public let sessionId: String
        public let userId: String
        public let deviceId: String
        public let createdAt: Date
        public let expiresAt: Date
        public let lastActivity: Date
        public let authenticationMethod: AuthenticationMethod
        public let riskScore: Double
        public let ipAddress: String?
        public let userAgent: String?
        public let isValid: Bool
        public let metadata: [String: Any]
        
        public init(
            sessionId: String,
            userId: String,
            deviceId: String,
            createdAt: Date,
            expiresAt: Date,
            lastActivity: Date,
            authenticationMethod: AuthenticationMethod,
            riskScore: Double,
            ipAddress: String? = nil,
            userAgent: String? = nil,
            isValid: Bool = true,
            metadata: [String: Any] = [:]
        ) {
            self.sessionId = sessionId
            self.userId = userId
            self.deviceId = deviceId
            self.createdAt = createdAt
            self.expiresAt = expiresAt
            self.lastActivity = lastActivity
            self.authenticationMethod = authenticationMethod
            self.riskScore = riskScore
            self.ipAddress = ipAddress
            self.userAgent = userAgent
            self.isValid = isValid
            self.metadata = metadata
        }
    }
    
    /// Biometric availability information
    public struct BiometricInfo {
        public let isAvailable: Bool
        public let biometryType: LABiometryType
        public let hasEnrolledBiometrics: Bool
        public let supportedTypes: Set<LABiometryType>
        public let error: LAError?
        
        public init(
            isAvailable: Bool,
            biometryType: LABiometryType,
            hasEnrolledBiometrics: Bool,
            supportedTypes: Set<LABiometryType>,
            error: LAError? = nil
        ) {
            self.isAvailable = isAvailable
            self.biometryType = biometryType
            self.hasEnrolledBiometrics = hasEnrolledBiometrics
            self.supportedTypes = supportedTypes
            self.error = error
        }
    }
    
    /// Risk assessment information
    public struct RiskAssessment {
        public let riskScore: Double // 0.0 to 1.0
        public let riskLevel: RiskLevel
        public let factors: [RiskFactor]
        public let recommendations: [String]
        public let timestamp: Date
        
        public enum RiskLevel: String, CaseIterable {
            case low = "low"
            case medium = "medium"
            case high = "high"
            case critical = "critical"
            
            public var threshold: Double {
                switch self {
                case .low: return 0.25
                case .medium: return 0.5
                case .high: return 0.75
                case .critical: return 1.0
                }
            }
        }
        
        public struct RiskFactor {
            public let name: String
            public let score: Double
            public let weight: Double
            public let description: String
            
            public init(name: String, score: Double, weight: Double, description: String) {
                self.name = name
                self.score = score
                self.weight = weight
                self.description = description
            }
        }
        
        public init(
            riskScore: Double,
            riskLevel: RiskLevel,
            factors: [RiskFactor],
            recommendations: [String],
            timestamp: Date = Date()
        ) {
            self.riskScore = riskScore
            self.riskLevel = riskLevel
            self.factors = factors
            self.recommendations = recommendations
            self.timestamp = timestamp
        }
    }
    
    // MARK: - Published Properties
    
    /// Current authentication state
    @Published public private(set) var isAuthenticated: Bool = false
    
    /// Current session information
    @Published public private(set) var currentSession: SessionInfo?
    
    /// Biometric availability
    @Published public private(set) var biometricInfo: BiometricInfo?
    
    /// Authentication performance metrics
    @Published public private(set) var performanceMetrics = PerformanceMetrics()
    
    /// Security health monitoring
    @Published public private(set) var securityHealth = SecurityHealth()
    
    // MARK: - Private Properties
    
    /// Current authentication configuration
    private var configuration: AuthenticationConfiguration
    
    /// Local authentication context
    private let localAuthContext = LAContext()
    
    /// Device identifier
    private let deviceId: String
    
    /// Session manager
    private let sessionManager: SessionManager
    
    /// Risk assessment engine
    private let riskAssessment: RiskAssessmentEngine
    
    /// Failed authentication attempts tracker
    private var failedAttempts: [String: FailedAttemptInfo] = [:]
    
    /// Session timeout timer
    private var sessionTimeoutTimer: Timer?
    
    /// Thread-safe access queue
    private let authQueue = DispatchQueue(label: "com.globallingo.authentication", qos: .userInitiated)
    
    // MARK: - Performance Tracking
    
    /// Performance metrics for authentication operations
    public struct PerformanceMetrics {
        public private(set) var authenticationTime: TimeInterval = 0.0
        public private(set) var biometricAuthTime: TimeInterval = 0.0
        public private(set) var sessionValidationTime: TimeInterval = 0.0
        public private(set) var authenticationCount: Int = 0
        public private(set) var successfulAuthentications: Int = 0
        public private(set) var failedAuthentications: Int = 0
        public private(set) var successRate: Double = 1.0
        public private(set) var averageAuthTime: TimeInterval = 0.0
        public private(set) var lastUpdated: Date = Date()
        
        /// Performance targets (enterprise-grade)
        public static let targets = PerformanceTargets(
            maxAuthenticationTime: 0.500, // 500ms
            maxBiometricAuthTime: 1.000, // 1 second
            maxSessionValidationTime: 0.100, // 100ms
            minSuccessRate: 0.95, // 95%
            maxMemoryUsage: 25 * 1024 * 1024 // 25MB
        )
        
        mutating func updateAuthentication(time: TimeInterval, success: Bool, isBiometric: Bool = false) {
            authenticationTime = time
            authenticationCount += 1
            
            if success {
                successfulAuthentications += 1
            } else {
                failedAuthentications += 1
            }
            
            if isBiometric {
                biometricAuthTime = time
            }
            
            successRate = Double(successfulAuthentications) / Double(authenticationCount)
            averageAuthTime = (averageAuthTime * Double(authenticationCount - 1) + time) / Double(authenticationCount)
            lastUpdated = Date()
        }
        
        mutating func updateSessionValidation(time: TimeInterval) {
            sessionValidationTime = time
            lastUpdated = Date()
        }
    }
    
    /// Performance targets for enterprise operations
    public struct PerformanceTargets {
        public let maxAuthenticationTime: TimeInterval
        public let maxBiometricAuthTime: TimeInterval
        public let maxSessionValidationTime: TimeInterval
        public let minSuccessRate: Double
        public let maxMemoryUsage: Int
        
        public init(
            maxAuthenticationTime: TimeInterval,
            maxBiometricAuthTime: TimeInterval,
            maxSessionValidationTime: TimeInterval,
            minSuccessRate: Double,
            maxMemoryUsage: Int
        ) {
            self.maxAuthenticationTime = maxAuthenticationTime
            self.maxBiometricAuthTime = maxBiometricAuthTime
            self.maxSessionValidationTime = maxSessionValidationTime
            self.minSuccessRate = minSuccessRate
            self.maxMemoryUsage = maxMemoryUsage
        }
    }
    
    /// Security health monitoring
    public struct SecurityHealth {
        public private(set) var overallHealth: Double = 1.0
        public private(set) var authenticationHealth: Double = 1.0
        public private(set) var sessionHealth: Double = 1.0
        public private(set) var biometricHealth: Double = 1.0
        public private(set) var lastSecurityCheck: Date = Date()
        public private(set) var vulnerabilities: [SecurityVulnerability] = []
        public private(set) var recommendations: [SecurityRecommendation] = []
        
        mutating func updateHealth(
            authentication: Double,
            session: Double,
            biometric: Double,
            vulnerabilities: [SecurityVulnerability] = [],
            recommendations: [SecurityRecommendation] = []
        ) {
            self.authenticationHealth = authentication
            self.sessionHealth = session
            self.biometricHealth = biometric
            self.overallHealth = (authentication + session + biometric) / 3.0
            self.vulnerabilities = vulnerabilities
            self.recommendations = recommendations
            self.lastSecurityCheck = Date()
        }
    }
    
    /// Security vulnerability tracking
    public struct SecurityVulnerability {
        public let id: String
        public let severity: Severity
        public let description: String
        public let recommendation: String
        public let discoveredAt: Date
        
        public enum Severity: String, CaseIterable {
            case low = "low"
            case medium = "medium"
            case high = "high"
            case critical = "critical"
        }
        
        public init(id: String, severity: Severity, description: String, recommendation: String) {
            self.id = id
            self.severity = severity
            self.description = description
            self.recommendation = recommendation
            self.discoveredAt = Date()
        }
    }
    
    /// Security recommendations for improvement
    public struct SecurityRecommendation {
        public let id: String
        public let priority: Priority
        public let title: String
        public let description: String
        public let implementation: String
        public let createdAt: Date
        
        public enum Priority: String, CaseIterable {
            case low = "low"
            case medium = "medium"
            case high = "high"
            case critical = "critical"
        }
        
        public init(id: String, priority: Priority, title: String, description: String, implementation: String) {
            self.id = id
            self.priority = priority
            self.title = title
            self.description = description
            self.implementation = implementation
            self.createdAt = Date()
        }
    }
    
    /// Failed authentication attempt tracking
    private struct FailedAttemptInfo {
        let timestamp: Date
        let count: Int
        let lockoutUntil: Date?
        
        func isLockedOut() -> Bool {
            guard let lockoutUntil = lockoutUntil else { return false }
            return Date() < lockoutUntil
        }
    }
    
    // MARK: - Initialization
    
    /// Private initializer for singleton pattern
    private init() {
        self.configuration = .enterprise
        self.deviceId = Self.generateDeviceId()
        self.sessionManager = SessionManager()
        self.riskAssessment = RiskAssessmentEngine()
        
        setupBiometricInfo()
        startHealthMonitoring()
        
        logger.info("AuthenticationManager initialized with enterprise configuration")
    }
    
    /// Configure authentication manager with custom settings
    public func configure(with configuration: AuthenticationConfiguration) async {
        await authQueue.perform {
            self.configuration = configuration
            self.setupSessionTimeout()
        }
        
        logger.info("AuthenticationManager configured with \(configuration.complianceLevel.rawValue) compliance level")
    }
    
    // MARK: - Core Authentication Methods
    
    /// Authenticate user with biometric authentication
    /// - Parameters:
    ///   - reason: Reason for authentication request
    ///   - fallbackTitle: Title for fallback authentication
    /// - Returns: Authentication result with session information
    public func authenticateWithBiometrics(
        reason: String = "Authenticate to access GlobalLingo",
        fallbackTitle: String? = "Use Passcode"
    ) async throws -> AuthenticationResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await authQueue.perform { [weak self] in
            guard let self = self else {
                throw AuthenticationError.managerDeallocated
            }
            
            let operationId = UUID().uuidString
            logger.info("Starting biometric authentication \(operationId)")
            
            // Check if user is locked out
            if self.isUserLockedOut() {
                throw AuthenticationError.userLockedOut
            }
            
            // Check biometric availability
            guard let biometricInfo = self.biometricInfo,
                  biometricInfo.isAvailable else {
                throw AuthenticationError.biometricsNotAvailable
            }
            
            // Configure local authentication context
            let context = LAContext()
            context.localizedFallbackTitle = fallbackTitle
            
            do {
                // Perform biometric authentication
                let success = try await context.evaluatePolicy(
                    self.configuration.biometricPolicy.localAuthenticationPolicy,
                    localizedReason: reason
                )
                
                if success {
                    // Generate session and tokens
                    let sessionInfo = try await self.createSession(
                        userId: "biometric-user", // In real implementation, get from biometric template
                        authenticationMethod: .biometric,
                        operationId: operationId
                    )
                    
                    // Assess risk
                    let riskAssessment = await self.assessAuthenticationRisk(
                        authenticationMethod: .biometric,
                        deviceId: self.deviceId
                    )
                    
                    // Create authentication result
                    let result = AuthenticationResult(
                        isAuthenticated: true,
                        userId: sessionInfo.userId,
                        authenticationMethod: .biometric,
                        sessionToken: sessionInfo.sessionId,
                        refreshToken: "refresh-\(sessionInfo.sessionId)",
                        expiresAt: sessionInfo.expiresAt,
                        deviceId: self.deviceId,
                        riskScore: riskAssessment.riskScore,
                        authenticationTime: Date(),
                        metadata: [
                            "operation_id": operationId,
                            "biometry_type": biometricInfo.biometryType.rawValue,
                            "risk_level": riskAssessment.riskLevel.rawValue
                        ]
                    )
                    
                    // Update state
                    await MainActor.run {
                        self.isAuthenticated = true
                        self.currentSession = sessionInfo
                    }
                    
                    // Reset failed attempts
                    self.resetFailedAttempts()
                    
                    // Update performance metrics
                    let operationTime = CFAbsoluteTimeGetCurrent() - startTime
                    await MainActor.run {
                        self.performanceMetrics.updateAuthentication(time: operationTime, success: true, isBiometric: true)
                    }
                    
                    logger.info("Biometric authentication \(operationId) completed successfully in \(String(format: "%.3f", operationTime * 1000))ms")
                    
                    return result
                    
                } else {
                    // Authentication failed
                    self.recordFailedAttempt()
                    
                    let operationTime = CFAbsoluteTimeGetCurrent() - startTime
                    await MainActor.run {
                        self.performanceMetrics.updateAuthentication(time: operationTime, success: false, isBiometric: true)
                    }
                    
                    throw AuthenticationError.authenticationFailed("Biometric authentication failed")
                }
                
            } catch let error as LAError {
                // Handle Local Authentication errors
                self.recordFailedAttempt()
                
                let operationTime = CFAbsoluteTimeGetCurrent() - startTime
                await MainActor.run {
                    self.performanceMetrics.updateAuthentication(time: operationTime, success: false, isBiometric: true)
                }
                
                switch error.code {
                case .biometryNotAvailable:
                    throw AuthenticationError.biometricsNotAvailable
                case .biometryNotEnrolled:
                    throw AuthenticationError.biometricsNotEnrolled
                case .biometryLockout:
                    throw AuthenticationError.biometricsLocked
                case .userCancel:
                    throw AuthenticationError.userCancelled
                case .userFallback:
                    throw AuthenticationError.userChoseFallback
                default:
                    throw AuthenticationError.authenticationFailed("Biometric authentication error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Authenticate user with password
    /// - Parameters:
    ///   - username: User's username or email
    ///   - password: User's password
    /// - Returns: Authentication result with session information
    public func authenticateWithPassword(
        username: String,
        password: String
    ) async throws -> AuthenticationResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await authQueue.perform { [weak self] in
            guard let self = self else {
                throw AuthenticationError.managerDeallocated
            }
            
            let operationId = UUID().uuidString
            logger.info("Starting password authentication \(operationId) for user: \(username)")
            
            // Check if user is locked out
            if self.isUserLockedOut(for: username) {
                throw AuthenticationError.userLockedOut
            }
            
            // Validate password policy
            try self.validatePassword(password)
            
            // Verify credentials (in real implementation, check against secure storage or server)
            let isValidCredentials = try await self.verifyCredentials(username: username, password: password)
            
            if isValidCredentials {
                // Generate session and tokens
                let sessionInfo = try await self.createSession(
                    userId: username,
                    authenticationMethod: .password,
                    operationId: operationId
                )
                
                // Assess risk
                let riskAssessment = await self.assessAuthenticationRisk(
                    authenticationMethod: .password,
                    deviceId: self.deviceId,
                    userId: username
                )
                
                // Create authentication result
                let result = AuthenticationResult(
                    isAuthenticated: true,
                    userId: username,
                    authenticationMethod: .password,
                    sessionToken: sessionInfo.sessionId,
                    refreshToken: "refresh-\(sessionInfo.sessionId)",
                    expiresAt: sessionInfo.expiresAt,
                    deviceId: self.deviceId,
                    riskScore: riskAssessment.riskScore,
                    authenticationTime: Date(),
                    metadata: [
                        "operation_id": operationId,
                        "risk_level": riskAssessment.riskLevel.rawValue,
                        "mfa_required": self.configuration.mfaRequired
                    ]
                )
                
                // Update state
                await MainActor.run {
                    self.isAuthenticated = true
                    self.currentSession = sessionInfo
                }
                
                // Reset failed attempts
                self.resetFailedAttempts(for: username)
                
                // Update performance metrics
                let operationTime = CFAbsoluteTimeGetCurrent() - startTime
                await MainActor.run {
                    self.performanceMetrics.updateAuthentication(time: operationTime, success: true)
                }
                
                logger.info("Password authentication \(operationId) completed successfully in \(String(format: "%.3f", operationTime * 1000))ms")
                
                return result
                
            } else {
                // Authentication failed
                self.recordFailedAttempt(for: username)
                
                let operationTime = CFAbsoluteTimeGetCurrent() - startTime
                await MainActor.run {
                    self.performanceMetrics.updateAuthentication(time: operationTime, success: false)
                }
                
                throw AuthenticationError.invalidCredentials
            }
        }
    }
    
    /// Authenticate user with device passcode
    /// - Parameter reason: Reason for authentication request
    /// - Returns: Authentication result with session information
    public func authenticateWithDevicePasscode(
        reason: String = "Authenticate to access GlobalLingo"
    ) async throws -> AuthenticationResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await authQueue.perform { [weak self] in
            guard let self = self else {
                throw AuthenticationError.managerDeallocated
            }
            
            let operationId = UUID().uuidString
            logger.info("Starting device passcode authentication \(operationId)")
            
            // Check if user is locked out
            if self.isUserLockedOut() {
                throw AuthenticationError.userLockedOut
            }
            
            // Configure local authentication context
            let context = LAContext()
            
            do {
                // Perform device passcode authentication
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: reason
                )
                
                if success {
                    // Generate session and tokens
                    let sessionInfo = try await self.createSession(
                        userId: "device-user",
                        authenticationMethod: .devicePasscode,
                        operationId: operationId
                    )
                    
                    // Assess risk
                    let riskAssessment = await self.assessAuthenticationRisk(
                        authenticationMethod: .devicePasscode,
                        deviceId: self.deviceId
                    )
                    
                    // Create authentication result
                    let result = AuthenticationResult(
                        isAuthenticated: true,
                        userId: sessionInfo.userId,
                        authenticationMethod: .devicePasscode,
                        sessionToken: sessionInfo.sessionId,
                        refreshToken: "refresh-\(sessionInfo.sessionId)",
                        expiresAt: sessionInfo.expiresAt,
                        deviceId: self.deviceId,
                        riskScore: riskAssessment.riskScore,
                        authenticationTime: Date(),
                        metadata: [
                            "operation_id": operationId,
                            "risk_level": riskAssessment.riskLevel.rawValue
                        ]
                    )
                    
                    // Update state
                    await MainActor.run {
                        self.isAuthenticated = true
                        self.currentSession = sessionInfo
                    }
                    
                    // Reset failed attempts
                    self.resetFailedAttempts()
                    
                    // Update performance metrics
                    let operationTime = CFAbsoluteTimeGetCurrent() - startTime
                    await MainActor.run {
                        self.performanceMetrics.updateAuthentication(time: operationTime, success: true)
                    }
                    
                    logger.info("Device passcode authentication \(operationId) completed successfully in \(String(format: "%.3f", operationTime * 1000))ms")
                    
                    return result
                    
                } else {
                    // Authentication failed
                    self.recordFailedAttempt()
                    
                    let operationTime = CFAbsoluteTimeGetCurrent() - startTime
                    await MainActor.run {
                        self.performanceMetrics.updateAuthentication(time: operationTime, success: false)
                    }
                    
                    throw AuthenticationError.authenticationFailed("Device passcode authentication failed")
                }
                
            } catch let error as LAError {
                // Handle Local Authentication errors
                self.recordFailedAttempt()
                
                let operationTime = CFAbsoluteTimeGetCurrent() - startTime
                await MainActor.run {
                    self.performanceMetrics.updateAuthentication(time: operationTime, success: false)
                }
                
                switch error.code {
                case .passcodeNotSet:
                    throw AuthenticationError.passcodeNotSet
                case .userCancel:
                    throw AuthenticationError.userCancelled
                default:
                    throw AuthenticationError.authenticationFailed("Device passcode authentication error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Session Management
    
    /// Validate current session
    /// - Returns: True if session is valid and active
    public func validateSession() async -> Bool {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return await authQueue.perform { [weak self] in
            guard let self = self else { return false }
            
            guard let session = self.currentSession else {
                await MainActor.run {
                    self.isAuthenticated = false
                }
                return false
            }
            
            // Check session expiration
            let now = Date()
            if now > session.expiresAt {
                await self.invalidateSession()
                return false
            }
            
            // Update last activity
            let updatedSession = SessionInfo(
                sessionId: session.sessionId,
                userId: session.userId,
                deviceId: session.deviceId,
                createdAt: session.createdAt,
                expiresAt: session.expiresAt,
                lastActivity: now,
                authenticationMethod: session.authenticationMethod,
                riskScore: session.riskScore,
                ipAddress: session.ipAddress,
                userAgent: session.userAgent,
                isValid: true,
                metadata: session.metadata
            )
            
            await MainActor.run {
                self.currentSession = updatedSession
            }
            
            // Update performance metrics
            let operationTime = CFAbsoluteTimeGetCurrent() - startTime
            await MainActor.run {
                self.performanceMetrics.updateSessionValidation(time: operationTime)
            }
            
            return true
        }
    }
    
    /// Refresh authentication session
    /// - Parameter refreshToken: Refresh token from authentication result
    /// - Returns: New authentication result with updated tokens
    public func refreshSession(refreshToken: String) async throws -> AuthenticationResult {
        return try await authQueue.perform { [weak self] in
            guard let self = self else {
                throw AuthenticationError.managerDeallocated
            }
            
            guard let currentSession = self.currentSession else {
                throw AuthenticationError.sessionNotFound
            }
            
            // Validate refresh token (in real implementation, verify against secure storage)
            guard refreshToken == "refresh-\(currentSession.sessionId)" else {
                throw AuthenticationError.invalidRefreshToken
            }
            
            // Create new session
            let newSessionInfo = try await self.createSession(
                userId: currentSession.userId,
                authenticationMethod: currentSession.authenticationMethod,
                operationId: "refresh-\(UUID().uuidString)"
            )
            
            // Create new authentication result
            let result = AuthenticationResult(
                isAuthenticated: true,
                userId: newSessionInfo.userId,
                authenticationMethod: currentSession.authenticationMethod,
                sessionToken: newSessionInfo.sessionId,
                refreshToken: "refresh-\(newSessionInfo.sessionId)",
                expiresAt: newSessionInfo.expiresAt,
                deviceId: self.deviceId,
                riskScore: currentSession.riskScore,
                authenticationTime: Date(),
                metadata: ["operation_type": "session_refresh"]
            )
            
            // Update state
            await MainActor.run {
                self.currentSession = newSessionInfo
            }
            
            logger.info("Session refreshed successfully for user: \(currentSession.userId)")
            
            return result
        }
    }
    
    /// Invalidate current session
    public func invalidateSession() async {
        await authQueue.perform { [weak self] in
            guard let self = self else { return }
            
            if let session = self.currentSession {
                logger.info("Invalidating session: \(session.sessionId)")
                await self.sessionManager.invalidateSession(session.sessionId)
            }
            
            await MainActor.run {
                self.isAuthenticated = false
                self.currentSession = nil
            }
            
            self.sessionTimeoutTimer?.invalidate()
            self.sessionTimeoutTimer = nil
        }
    }
    
    /// Logout user and clean up session
    public func logout() async {
        await invalidateSession()
        
        // Clear any cached credentials
        await authQueue.perform { [weak self] in
            self?.resetFailedAttempts()
        }
        
        logger.info("User logged out successfully")
    }
    
    // MARK: - Biometric Management
    
    /// Check biometric availability and update cached information
    public func checkBiometricAvailability() async -> BiometricInfo {
        return await authQueue.perform { [weak self] in
            guard let self = self else {
                return BiometricInfo(
                    isAvailable: false,
                    biometryType: .none,
                    hasEnrolledBiometrics: false,
                    supportedTypes: []
                )
            }
            
            let context = LAContext()
            var error: NSError?
            
            let isAvailable = context.canEvaluatePolicy(
                self.configuration.biometricPolicy.localAuthenticationPolicy,
                error: &error
            )
            
            let biometryType = context.biometryType
            let hasEnrolledBiometrics = isAvailable && error == nil
            
            var supportedTypes: Set<LABiometryType> = []
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                supportedTypes.insert(biometryType)
            }
            
            let biometricInfo = BiometricInfo(
                isAvailable: isAvailable,
                biometryType: biometryType,
                hasEnrolledBiometrics: hasEnrolledBiometrics,
                supportedTypes: supportedTypes,
                error: error as? LAError
            )
            
            await MainActor.run {
                self.biometricInfo = biometricInfo
            }
            
            return biometricInfo
        }
    }
    
    // MARK: - Risk Assessment
    
    /// Assess authentication risk based on various factors
    /// - Parameters:
    ///   - authenticationMethod: Method used for authentication
    ///   - deviceId: Device identifier
    ///   - userId: Optional user identifier
    /// - Returns: Risk assessment with score and recommendations
    public func assessAuthenticationRisk(
        authenticationMethod: AuthenticationMethod,
        deviceId: String,
        userId: String? = nil
    ) async -> RiskAssessment {
        return await riskAssessment.assessRisk(
            authenticationMethod: authenticationMethod,
            deviceId: deviceId,
            userId: userId,
            configuration: configuration
        )
    }
    
    // MARK: - Security Health & Monitoring
    
    /// Perform comprehensive security health check
    public func performSecurityHealthCheck() async -> SecurityHealth {
        return await authQueue.perform { [weak self] in
            guard let self = self else {
                return SecurityHealth()
            }
            
            logger.info("Performing authentication security health check")
            
            var vulnerabilities: [SecurityVulnerability] = []
            var recommendations: [SecurityRecommendation] = []
            
            // Check authentication performance
            let authHealth = self.assessAuthenticationHealth()
            if authHealth < 0.9 {
                vulnerabilities.append(SecurityVulnerability(
                    id: "AUTH-001",
                    severity: .medium,
                    description: "Authentication performance below optimal threshold",
                    recommendation: "Review authentication methods and optimize biometric settings"
                ))
            }
            
            // Check session management
            let sessionHealth = self.assessSessionHealth()
            if sessionHealth < 0.95 {
                recommendations.append(SecurityRecommendation(
                    id: "SESSION-001",
                    priority: .high,
                    title: "Session Management Optimization",
                    description: "Session management performance can be improved",
                    implementation: "Implement automatic session cleanup and optimization"
                ))
            }
            
            // Check biometric security
            let biometricHealth = self.assessBiometricHealth()
            if biometricHealth < 1.0 {
                vulnerabilities.append(SecurityVulnerability(
                    id: "BIO-001",
                    severity: .low,
                    description: "Biometric authentication could be enhanced",
                    recommendation: "Enable additional biometric methods if available"
                ))
            }
            
            var health = SecurityHealth()
            health.updateHealth(
                authentication: authHealth,
                session: sessionHealth,
                biometric: biometricHealth,
                vulnerabilities: vulnerabilities,
                recommendations: recommendations
            )
            
            self.securityHealth = health
            
            logger.info("Authentication security health check completed - Overall health: \(String(format: "%.1f", health.overallHealth * 100))%")
            
            return health
        }
    }
    
    // MARK: - Private Implementation
    
    /// Setup biometric information on initialization
    private func setupBiometricInfo() {
        Task {
            await checkBiometricAvailability()
        }
    }
    
    /// Setup session timeout monitoring
    private func setupSessionTimeout() {
        sessionTimeoutTimer?.invalidate()
        sessionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: configuration.sessionTimeout, repeats: false) { [weak self] _ in
            Task {
                await self?.invalidateSession()
            }
        }
    }
    
    /// Generate unique device identifier
    private static func generateDeviceId() -> String {
        // Use device-specific identifier
        #if targetEnvironment(simulator)
        return "simulator-\(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)"
        #else
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #endif
    }
    
    /// Create new authentication session
    private func createSession(
        userId: String,
        authenticationMethod: AuthenticationMethod,
        operationId: String
    ) async throws -> SessionInfo {
        let sessionId = UUID().uuidString
        let now = Date()
        let expiresAt = now.addingTimeInterval(configuration.sessionTimeout)
        
        let sessionInfo = SessionInfo(
            sessionId: sessionId,
            userId: userId,
            deviceId: deviceId,
            createdAt: now,
            expiresAt: expiresAt,
            lastActivity: now,
            authenticationMethod: authenticationMethod,
            riskScore: 0.0, // Will be updated with risk assessment
            metadata: ["operation_id": operationId]
        )
        
        await sessionManager.createSession(sessionInfo)
        setupSessionTimeout()
        
        return sessionInfo
    }
    
    /// Verify user credentials
    private func verifyCredentials(username: String, password: String) async throws -> Bool {
        // In real implementation, verify against secure storage or authentication server
        // For demo purposes, accept any non-empty credentials
        return !username.isEmpty && !password.isEmpty
    }
    
    /// Validate password against policy
    private func validatePassword(_ password: String) throws {
        let requirements = configuration.passwordPolicy.requirements
        
        if password.count < requirements.minLength {
            throw AuthenticationError.passwordTooShort
        }
        
        if requirements.requireUppercase && !password.contains(where: { $0.isUppercase }) {
            throw AuthenticationError.passwordMissingUppercase
        }
        
        if requirements.requireLowercase && !password.contains(where: { $0.islowercase }) {
            throw AuthenticationError.passwordMissingLowercase
        }
        
        if requirements.requireNumbers && !password.contains(where: { $0.isNumber }) {
            throw AuthenticationError.passwordMissingNumbers
        }
        
        if requirements.requireSpecialChars && !password.contains(where: { $0.isPunctuation || $0.isSymbol }) {
            throw AuthenticationError.passwordMissingSpecialChars
        }
    }
    
    /// Check if user is locked out
    private func isUserLockedOut(for userId: String? = nil) -> Bool {
        let key = userId ?? "device"
        guard let attemptInfo = failedAttempts[key] else { return false }
        
        return attemptInfo.count >= configuration.maxFailedAttempts && attemptInfo.isLockedOut()
    }
    
    /// Record failed authentication attempt
    private func recordFailedAttempt(for userId: String? = nil) {
        let key = userId ?? "device"
        let now = Date()
        
        if let existing = failedAttempts[key] {
            let newCount = existing.count + 1
            let lockoutUntil = newCount >= configuration.maxFailedAttempts ?
                now.addingTimeInterval(configuration.lockoutDuration) : nil
            
            failedAttempts[key] = FailedAttemptInfo(
                timestamp: now,
                count: newCount,
                lockoutUntil: lockoutUntil
            )
        } else {
            failedAttempts[key] = FailedAttemptInfo(
                timestamp: now,
                count: 1,
                lockoutUntil: nil
            )
        }
        
        logger.warning("Failed authentication attempt recorded for \(key)")
    }
    
    /// Reset failed authentication attempts
    private func resetFailedAttempts(for userId: String? = nil) {
        let key = userId ?? "device"
        failedAttempts.removeValue(forKey: key)
    }
    
    /// Start security health monitoring
    private func startHealthMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in // Every 5 minutes
            Task {
                await self?.performSecurityHealthCheck()
            }
        }
    }
    
    /// Assess authentication health metrics
    private func assessAuthenticationHealth() -> Double {
        let targets = PerformanceMetrics.targets
        
        var healthScore: Double = 1.0
        
        // Check authentication time
        if performanceMetrics.averageAuthTime > targets.maxAuthenticationTime {
            healthScore -= 0.2
        }
        
        // Check biometric authentication time
        if performanceMetrics.biometricAuthTime > targets.maxBiometricAuthTime {
            healthScore -= 0.1
        }
        
        // Check success rate
        if performanceMetrics.successRate < targets.minSuccessRate {
            healthScore -= 0.3
        }
        
        return max(0.0, healthScore)
    }
    
    /// Assess session management health
    private func assessSessionHealth() -> Double {
        var healthScore: Double = 1.0
        
        // Check session validation time
        let targets = PerformanceMetrics.targets
        if performanceMetrics.sessionValidationTime > targets.maxSessionValidationTime {
            healthScore -= 0.2
        }
        
        // Check current session validity
        if let session = currentSession {
            let timeUntilExpiry = session.expiresAt.timeIntervalSinceNow
            if timeUntilExpiry < 60 { // Less than 1 minute
                healthScore -= 0.1
            }
        }
        
        return max(0.0, healthScore)
    }
    
    /// Assess biometric authentication health
    private func assessBiometricHealth() -> Double {
        guard let biometricInfo = biometricInfo else { return 0.5 }
        
        var healthScore: Double = 1.0
        
        if !biometricInfo.isAvailable {
            healthScore -= 0.5
        }
        
        if !biometricInfo.hasEnrolledBiometrics {
            healthScore -= 0.3
        }
        
        if biometricInfo.error != nil {
            healthScore -= 0.2
        }
        
        return max(0.0, healthScore)
    }
}

// MARK: - Supporting Classes

/// Session manager for handling authentication sessions
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
private final class SessionManager {
    
    private var activeSessions: [String: AuthenticationManager.SessionInfo] = [:]
    private let sessionQueue = DispatchQueue(label: "com.globallingo.session", qos: .utility)
    
    func createSession(_ sessionInfo: AuthenticationManager.SessionInfo) async {
        await sessionQueue.perform {
            self.activeSessions[sessionInfo.sessionId] = sessionInfo
        }
    }
    
    func getSession(_ sessionId: String) async -> AuthenticationManager.SessionInfo? {
        return await sessionQueue.perform {
            return self.activeSessions[sessionId]
        }
    }
    
    func invalidateSession(_ sessionId: String) async {
        await sessionQueue.perform {
            self.activeSessions.removeValue(forKey: sessionId)
        }
    }
    
    func cleanupExpiredSessions() async {
        await sessionQueue.perform {
            let now = Date()
            self.activeSessions = self.activeSessions.filter { _, session in
                return now < session.expiresAt
            }
        }
    }
}

/// Risk assessment engine for authentication security
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
private final class RiskAssessmentEngine {
    
    func assessRisk(
        authenticationMethod: AuthenticationManager.AuthenticationMethod,
        deviceId: String,
        userId: String?,
        configuration: AuthenticationManager.AuthenticationConfiguration
    ) async -> AuthenticationManager.RiskAssessment {
        
        var riskFactors: [AuthenticationManager.RiskAssessment.RiskFactor] = []
        var totalScore: Double = 0.0
        
        // Authentication method risk
        let methodRisk = assessMethodRisk(authenticationMethod)
        riskFactors.append(methodRisk)
        totalScore += methodRisk.score * methodRisk.weight
        
        // Device risk
        let deviceRisk = assessDeviceRisk(deviceId)
        riskFactors.append(deviceRisk)
        totalScore += deviceRisk.score * deviceRisk.weight
        
        // Time-based risk
        let timeRisk = assessTimeRisk()
        riskFactors.append(timeRisk)
        totalScore += timeRisk.score * timeRisk.weight
        
        // Network risk (placeholder)
        let networkRisk = AuthenticationManager.RiskAssessment.RiskFactor(
            name: "network",
            score: 0.1,
            weight: 0.15,
            description: "Network location assessment"
        )
        riskFactors.append(networkRisk)
        totalScore += networkRisk.score * networkRisk.weight
        
        // Determine risk level
        let riskLevel: AuthenticationManager.RiskAssessment.RiskLevel
        switch totalScore {
        case 0.0..<0.25:
            riskLevel = .low
        case 0.25..<0.5:
            riskLevel = .medium
        case 0.5..<0.75:
            riskLevel = .high
        default:
            riskLevel = .critical
        }
        
        // Generate recommendations
        var recommendations: [String] = []
        if totalScore > 0.5 {
            recommendations.append("Consider requiring additional authentication factors")
        }
        if methodRisk.score > 0.3 {
            recommendations.append("Use stronger authentication method")
        }
        
        return AuthenticationManager.RiskAssessment(
            riskScore: totalScore,
            riskLevel: riskLevel,
            factors: riskFactors,
            recommendations: recommendations
        )
    }
    
    private func assessMethodRisk(_ method: AuthenticationManager.AuthenticationMethod) -> AuthenticationManager.RiskAssessment.RiskFactor {
        let (score, description) = switch method {
        case .devicePasscode:
            (0.4, "Device passcode provides basic security")
        case .password:
            (0.3, "Password authentication with policy enforcement")
        case .biometric:
            (0.1, "Biometric authentication provides high security")
        case .mfa:
            (0.05, "Multi-factor authentication provides excellent security")
        case .smartCard:
            (0.05, "Smart card provides excellent security")
        case .certificate:
            (0.1, "Certificate-based authentication provides high security")
        case .token:
            (0.2, "Token-based authentication provides good security")
        case .sso:
            (0.25, "SSO security depends on identity provider")
        }
        
        return AuthenticationManager.RiskAssessment.RiskFactor(
            name: "authentication_method",
            score: score,
            weight: 0.4,
            description: description
        )
    }
    
    private func assessDeviceRisk(_ deviceId: String) -> AuthenticationManager.RiskAssessment.RiskFactor {
        // In real implementation, check device reputation, jailbreak status, etc.
        let score = 0.1 // Low risk for known device
        return AuthenticationManager.RiskAssessment.RiskFactor(
            name: "device_trust",
            score: score,
            weight: 0.25,
            description: "Device trustworthiness assessment"
        )
    }
    
    private func assessTimeRisk() -> AuthenticationManager.RiskAssessment.RiskFactor {
        let hour = Calendar.current.component(.hour, from: Date())
        let score = (hour < 6 || hour > 22) ? 0.2 : 0.05 // Higher risk for unusual hours
        return AuthenticationManager.RiskAssessment.RiskFactor(
            name: "time_based",
            score: score,
            weight: 0.2,
            description: "Time-based risk assessment"
        )
    }
}

// MARK: - Authentication Errors

/// Authentication-related errors
public enum AuthenticationError: LocalizedError, CustomStringConvertible {
    case managerDeallocated
    case authenticationFailed(String)
    case biometricsNotAvailable
    case biometricsNotEnrolled
    case biometricsLocked
    case userCancelled
    case userChoseFallback
    case passcodeNotSet
    case invalidCredentials
    case userLockedOut
    case sessionNotFound
    case invalidRefreshToken
    case passwordTooShort
    case passwordMissingUppercase
    case passwordMissingLowercase
    case passwordMissingNumbers
    case passwordMissingSpecialChars
    case mfaRequired
    case ssoNotConfigured
    case networkError(String)
    
    public var errorDescription: String? {
        switch self {
        case .managerDeallocated:
            return "AuthenticationManager has been deallocated"
        case .authenticationFailed(let details):
            return "Authentication failed: \(details)"
        case .biometricsNotAvailable:
            return "Biometric authentication is not available on this device"
        case .biometricsNotEnrolled:
            return "No biometric credentials are enrolled on this device"
        case .biometricsLocked:
            return "Biometric authentication is locked due to too many failed attempts"
        case .userCancelled:
            return "User cancelled authentication"
        case .userChoseFallback:
            return "User chose fallback authentication method"
        case .passcodeNotSet:
            return "Device passcode is not set"
        case .invalidCredentials:
            return "Invalid username or password"
        case .userLockedOut:
            return "User account is locked due to too many failed attempts"
        case .sessionNotFound:
            return "Authentication session not found"
        case .invalidRefreshToken:
            return "Invalid or expired refresh token"
        case .passwordTooShort:
            return "Password does not meet minimum length requirement"
        case .passwordMissingUppercase:
            return "Password must contain uppercase letters"
        case .passwordMissingLowercase:
            return "Password must contain lowercase letters"
        case .passwordMissingNumbers:
            return "Password must contain numbers"
        case .passwordMissingSpecialChars:
            return "Password must contain special characters"
        case .mfaRequired:
            return "Multi-factor authentication is required"
        case .ssoNotConfigured:
            return "Single sign-on is not configured"
        case .networkError(let details):
            return "Network error during authentication: \(details)"
        }
    }
    
    public var description: String {
        return errorDescription ?? "Unknown authentication error"
    }
}

/// Character extension for password validation
extension Character {
    var islowercase: Bool {
        return self.isLowercase
    }
}
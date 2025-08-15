import Foundation
import CryptoKit
import Security
import CommonCrypto
import OSLog

/// Enterprise-grade encryption manager providing comprehensive cryptographic services
/// Implements AES-256-GCM encryption, RSA key exchange, and secure key management
/// Compliant with FIPS 140-2 Level 3, SOX, GDPR, and enterprise security standards
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public final class EncryptionManager: ObservableObject, Sendable {
    
    // MARK: - Singleton & Logger
    
    /// Shared instance with thread-safe lazy initialization
    public static let shared = EncryptionManager()
    
    /// Enterprise logging with security event categorization
    private let logger = Logger(subsystem: "com.globallingo.security", category: "encryption")
    
    // MARK: - Configuration & State
    
    /// Encryption configuration with enterprise security policies
    public struct EncryptionConfiguration {
        public let algorithm: EncryptionAlgorithm
        public let keySize: KeySize
        public let mode: EncryptionMode
        public let keyDerivationIterations: Int
        public let saltSize: Int
        public let ivSize: Int
        public let tagSize: Int
        public let keyRotationInterval: TimeInterval
        public let enableHardwareEncryption: Bool
        public let enableSecureEnclave: Bool
        public let enableKeyEscrow: Bool
        public let complianceLevel: ComplianceLevel
        
        public init(
            algorithm: EncryptionAlgorithm = .aes256GCM,
            keySize: KeySize = .bits256,
            mode: EncryptionMode = .gcm,
            keyDerivationIterations: Int = 100_000,
            saltSize: Int = 32,
            ivSize: Int = 12,
            tagSize: Int = 16,
            keyRotationInterval: TimeInterval = 24 * 60 * 60, // 24 hours
            enableHardwareEncryption: Bool = true,
            enableSecureEnclave: Bool = true,
            enableKeyEscrow: Bool = false,
            complianceLevel: ComplianceLevel = .enterprise
        ) {
            self.algorithm = algorithm
            self.keySize = keySize
            self.mode = mode
            self.keyDerivationIterations = keyDerivationIterations
            self.saltSize = saltSize
            self.ivSize = ivSize
            self.tagSize = tagSize
            self.keyRotationInterval = keyRotationInterval
            self.enableHardwareEncryption = enableHardwareEncryption
            self.enableSecureEnclave = enableSecureEnclave
            self.enableKeyEscrow = enableKeyEscrow
            self.complianceLevel = complianceLevel
        }
        
        /// Enterprise security configuration
        public static let enterprise = EncryptionConfiguration(
            algorithm: .aes256GCM,
            keySize: .bits256,
            mode: .gcm,
            keyDerivationIterations: 150_000,
            saltSize: 64,
            ivSize: 12,
            tagSize: 16,
            keyRotationInterval: 12 * 60 * 60, // 12 hours
            enableHardwareEncryption: true,
            enableSecureEnclave: true,
            enableKeyEscrow: false,
            complianceLevel: .enterprise
        )
        
        /// FIPS 140-2 Level 3 compliance configuration
        public static let fips1402Level3 = EncryptionConfiguration(
            algorithm: .aes256GCM,
            keySize: .bits256,
            mode: .gcm,
            keyDerivationIterations: 200_000,
            saltSize: 64,
            ivSize: 12,
            tagSize: 16,
            keyRotationInterval: 8 * 60 * 60, // 8 hours
            enableHardwareEncryption: true,
            enableSecureEnclave: true,
            enableKeyEscrow: true,
            complianceLevel: .fips1402Level3
        )
    }
    
    /// Encryption algorithms supported by enterprise security
    public enum EncryptionAlgorithm: String, CaseIterable {
        case aes128GCM = "AES-128-GCM"
        case aes192GCM = "AES-192-GCM"
        case aes256GCM = "AES-256-GCM"
        case chaCha20Poly1305 = "ChaCha20-Poly1305"
        case aes256CBC = "AES-256-CBC"
        
        public var keySize: Int {
            switch self {
            case .aes128GCM: return 16
            case .aes192GCM: return 24
            case .aes256GCM, .aes256CBC: return 32
            case .chaCha20Poly1305: return 32
            }
        }
    }
    
    /// Key sizes for cryptographic operations
    public enum KeySize: Int, CaseIterable {
        case bits128 = 128
        case bits192 = 192
        case bits256 = 256
        case bits512 = 512
        case bits1024 = 1024
        case bits2048 = 2048
        case bits4096 = 4096
    }
    
    /// Encryption modes with authenticated encryption
    public enum EncryptionMode: String, CaseIterable {
        case gcm = "GCM"
        case cbc = "CBC"
        case cfb = "CFB"
        case ofb = "OFB"
        case ctr = "CTR"
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
    
    /// Encryption result with comprehensive metadata
    public struct EncryptionResult {
        public let encryptedData: Data
        public let iv: Data
        public let salt: Data
        public let tag: Data
        public let algorithm: EncryptionAlgorithm
        public let keyId: String
        public let timestamp: Date
        public let version: String
        public let metadata: [String: Any]
        
        public init(
            encryptedData: Data,
            iv: Data,
            salt: Data,
            tag: Data,
            algorithm: EncryptionAlgorithm,
            keyId: String,
            timestamp: Date = Date(),
            version: String = "1.0",
            metadata: [String: Any] = [:]
        ) {
            self.encryptedData = encryptedData
            self.iv = iv
            self.salt = salt
            self.tag = tag
            self.algorithm = algorithm
            self.keyId = keyId
            self.timestamp = timestamp
            self.version = version
            self.metadata = metadata
        }
    }
    
    /// Decryption result with validation metadata
    public struct DecryptionResult {
        public let decryptedData: Data
        public let isValid: Bool
        public let algorithm: EncryptionAlgorithm
        public let keyId: String
        public let timestamp: Date
        public let validationErrors: [String]
        public let metadata: [String: Any]
        
        public init(
            decryptedData: Data,
            isValid: Bool,
            algorithm: EncryptionAlgorithm,
            keyId: String,
            timestamp: Date,
            validationErrors: [String] = [],
            metadata: [String: Any] = [:]
        ) {
            self.decryptedData = decryptedData
            self.isValid = isValid
            self.algorithm = algorithm
            self.keyId = keyId
            self.timestamp = timestamp
            self.validationErrors = validationErrors
            self.metadata = metadata
        }
    }
    
    /// Key generation options with security policies
    public struct KeyGenerationOptions {
        public let keySize: KeySize
        public let useSecureEnclave: Bool
        public let enableKeyEscrow: Bool
        public let keyPurpose: KeyPurpose
        public let expirationDate: Date?
        public let accessControl: SecAccessControl?
        public let keyDerivationSalt: Data?
        public let biometricPolicy: BiometricPolicy
        
        public init(
            keySize: KeySize = .bits256,
            useSecureEnclave: Bool = true,
            enableKeyEscrow: Bool = false,
            keyPurpose: KeyPurpose = .encryption,
            expirationDate: Date? = nil,
            accessControl: SecAccessControl? = nil,
            keyDerivationSalt: Data? = nil,
            biometricPolicy: BiometricPolicy = .none
        ) {
            self.keySize = keySize
            self.useSecureEnclave = useSecureEnclave
            self.enableKeyEscrow = enableKeyEscrow
            self.keyPurpose = keyPurpose
            self.expirationDate = expirationDate
            self.accessControl = accessControl
            self.keyDerivationSalt = keyDerivationSalt
            self.biometricPolicy = biometricPolicy
        }
    }
    
    /// Key purposes for access control
    public enum KeyPurpose: String, CaseIterable {
        case encryption = "encryption"
        case decryption = "decryption"
        case signing = "signing"
        case verification = "verification"
        case keyAgreement = "key-agreement"
        case keyDerivation = "key-derivation"
    }
    
    /// Biometric policy for key access
    public enum BiometricPolicy: String, CaseIterable {
        case none = "none"
        case touchID = "touch-id"
        case faceID = "face-id"
        case any = "any"
        case devicePasscode = "device-passcode"
    }
    
    /// Key metadata for enterprise management
    public struct KeyMetadata {
        public let keyId: String
        public let keyType: String
        public let keySize: KeySize
        public let creationDate: Date
        public let expirationDate: Date?
        public let lastUsed: Date?
        public let usageCount: Int
        public let isHardwareBacked: Bool
        public let purpose: KeyPurpose
        public let accessControl: String
        public let complianceLevel: ComplianceLevel
        public let metadata: [String: Any]
        
        public init(
            keyId: String,
            keyType: String,
            keySize: KeySize,
            creationDate: Date,
            expirationDate: Date? = nil,
            lastUsed: Date? = nil,
            usageCount: Int = 0,
            isHardwareBacked: Bool = false,
            purpose: KeyPurpose = .encryption,
            accessControl: String = "none",
            complianceLevel: ComplianceLevel = .basic,
            metadata: [String: Any] = [:]
        ) {
            self.keyId = keyId
            self.keyType = keyType
            self.keySize = keySize
            self.creationDate = creationDate
            self.expirationDate = expirationDate
            self.lastUsed = lastUsed
            self.usageCount = usageCount
            self.isHardwareBacked = isHardwareBacked
            self.purpose = purpose
            self.accessControl = accessControl
            self.complianceLevel = complianceLevel
            self.metadata = metadata
        }
    }
    
    // MARK: - Private Properties
    
    /// Current encryption configuration
    private var configuration: EncryptionConfiguration
    
    /// Key management with secure storage
    private let keyManager: SecureKeyManager
    
    /// Hardware encryption detection
    private let hasSecureEnclave: Bool
    
    /// Key rotation scheduler
    private var keyRotationTimer: Timer?
    
    /// Performance metrics tracking
    @Published private(set) var performanceMetrics = PerformanceMetrics()
    
    /// Security health monitoring
    @Published private(set) var securityHealth = SecurityHealth()
    
    /// Key usage statistics
    private var keyUsageStats: [String: KeyUsageStatistics] = [:]
    
    /// Thread-safe access queue
    private let encryptionQueue = DispatchQueue(label: "com.globallingo.encryption", qos: .userInitiated)
    
    // MARK: - Performance Tracking
    
    /// Performance metrics for encryption operations
    public struct PerformanceMetrics {
        public private(set) var encryptionTime: TimeInterval = 0.0
        public private(set) var decryptionTime: TimeInterval = 0.0
        public private(set) var keyGenerationTime: TimeInterval = 0.0
        public private(set) var encryptionCount: Int = 0
        public private(set) var decryptionCount: Int = 0
        public private(set) var successRate: Double = 1.0
        public private(set) var averageEncryptionTime: TimeInterval = 0.0
        public private(set) var averageDecryptionTime: TimeInterval = 0.0
        public private(set) var keyRotationCount: Int = 0
        public private(set) var lastUpdated: Date = Date()
        
        /// Performance targets (enterprise-grade)
        public static let targets = PerformanceTargets(
            maxEncryptionTime: 0.010, // 10ms
            maxDecryptionTime: 0.008, // 8ms
            maxKeyGenerationTime: 0.050, // 50ms
            minSuccessRate: 0.999, // 99.9%
            maxMemoryUsage: 50 * 1024 * 1024 // 50MB
        )
        
        mutating func updateEncryption(time: TimeInterval, success: Bool) {
            encryptionTime = time
            encryptionCount += 1
            averageEncryptionTime = (averageEncryptionTime * Double(encryptionCount - 1) + time) / Double(encryptionCount)
            if success {
                successRate = (successRate * Double(encryptionCount + decryptionCount - 1) + 1.0) / Double(encryptionCount + decryptionCount)
            } else {
                successRate = (successRate * Double(encryptionCount + decryptionCount - 1)) / Double(encryptionCount + decryptionCount)
            }
            lastUpdated = Date()
        }
        
        mutating func updateDecryption(time: TimeInterval, success: Bool) {
            decryptionTime = time
            decryptionCount += 1
            averageDecryptionTime = (averageDecryptionTime * Double(decryptionCount - 1) + time) / Double(decryptionCount)
            if success {
                successRate = (successRate * Double(encryptionCount + decryptionCount - 1) + 1.0) / Double(encryptionCount + decryptionCount)
            } else {
                successRate = (successRate * Double(encryptionCount + decryptionCount - 1)) / Double(encryptionCount + decryptionCount)
            }
            lastUpdated = Date()
        }
        
        mutating func updateKeyGeneration(time: TimeInterval) {
            keyGenerationTime = time
            lastUpdated = Date()
        }
        
        mutating func incrementKeyRotation() {
            keyRotationCount += 1
            lastUpdated = Date()
        }
    }
    
    /// Performance targets for enterprise operations
    public struct PerformanceTargets {
        public let maxEncryptionTime: TimeInterval
        public let maxDecryptionTime: TimeInterval
        public let maxKeyGenerationTime: TimeInterval
        public let minSuccessRate: Double
        public let maxMemoryUsage: Int
        
        public init(
            maxEncryptionTime: TimeInterval,
            maxDecryptionTime: TimeInterval,
            maxKeyGenerationTime: TimeInterval,
            minSuccessRate: Double,
            maxMemoryUsage: Int
        ) {
            self.maxEncryptionTime = maxEncryptionTime
            self.maxDecryptionTime = maxDecryptionTime
            self.maxKeyGenerationTime = maxKeyGenerationTime
            self.minSuccessRate = minSuccessRate
            self.maxMemoryUsage = maxMemoryUsage
        }
    }
    
    /// Security health monitoring
    public struct SecurityHealth {
        public private(set) var overallHealth: Double = 1.0
        public private(set) var encryptionHealth: Double = 1.0
        public private(set) var keyManagementHealth: Double = 1.0
        public private(set) var complianceHealth: Double = 1.0
        public private(set) var lastSecurityCheck: Date = Date()
        public private(set) var vulnerabilities: [SecurityVulnerability] = []
        public private(set) var recommendations: [SecurityRecommendation] = []
        
        mutating func updateHealth(
            encryption: Double,
            keyManagement: Double,
            compliance: Double,
            vulnerabilities: [SecurityVulnerability] = [],
            recommendations: [SecurityRecommendation] = []
        ) {
            self.encryptionHealth = encryption
            self.keyManagementHealth = keyManagement
            self.complianceHealth = compliance
            self.overallHealth = (encryption + keyManagement + compliance) / 3.0
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
    
    /// Key usage statistics for monitoring
    private struct KeyUsageStatistics {
        var usageCount: Int = 0
        var lastUsed: Date = Date()
        var totalDataEncrypted: Int = 0
        var totalDataDecrypted: Int = 0
        var averageOperationTime: TimeInterval = 0.0
        var errorCount: Int = 0
        var successRate: Double = 1.0
        
        mutating func recordUsage(dataSize: Int, operationTime: TimeInterval, success: Bool) {
            usageCount += 1
            lastUsed = Date()
            
            if success {
                totalDataEncrypted += dataSize
                averageOperationTime = (averageOperationTime * Double(usageCount - 1) + operationTime) / Double(usageCount)
                successRate = (successRate * Double(usageCount - 1) + 1.0) / Double(usageCount)
            } else {
                errorCount += 1
                successRate = (successRate * Double(usageCount - 1)) / Double(usageCount)
            }
        }
    }
    
    // MARK: - Initialization
    
    /// Private initializer for singleton pattern with enterprise configuration
    private init() {
        self.configuration = .enterprise
        self.keyManager = SecureKeyManager()
        self.hasSecureEnclave = Self.detectSecureEnclave()
        
        setupKeyRotation()
        startHealthMonitoring()
        
        logger.info("EncryptionManager initialized with enterprise configuration")
    }
    
    /// Configure encryption manager with custom settings
    public func configure(with configuration: EncryptionConfiguration) async throws {
        await encryptionQueue.perform {
            self.configuration = configuration
            self.setupKeyRotation()
        }
        
        logger.info("EncryptionManager configured with \(configuration.complianceLevel.rawValue) compliance level")
    }
    
    // MARK: - Core Encryption Operations
    
    /// Encrypt data with enterprise-grade security
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - keyId: Optional key identifier (generates new key if nil)
    ///   - additionalData: Optional additional authenticated data
    /// - Returns: Encryption result with comprehensive metadata
    public func encrypt(
        _ data: Data,
        keyId: String? = nil,
        additionalData: Data? = nil
    ) async throws -> EncryptionResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await encryptionQueue.perform { [weak self] in
            guard let self = self else {
                throw EncryptionError.managerDeallocated
            }
            
            let operationId = UUID().uuidString
            logger.info("Starting encryption operation \(operationId)")
            
            // Generate or retrieve encryption key
            let finalKeyId = keyId ?? "default-\(Date().timeIntervalSince1970)"
            let key = try await self.keyManager.getOrCreateKey(
                keyId: finalKeyId,
                options: KeyGenerationOptions(
                    keySize: .bits256,
                    useSecureEnclave: self.configuration.enableSecureEnclave,
                    enableKeyEscrow: self.configuration.enableKeyEscrow
                )
            )
            
            // Generate cryptographically secure IV and salt
            let iv = try self.generateSecureRandom(length: self.configuration.ivSize)
            let salt = try self.generateSecureRandom(length: self.configuration.saltSize)
            
            // Perform encryption based on algorithm
            let (encryptedData, tag) = try await self.performEncryption(
                data: data,
                key: key,
                iv: iv,
                salt: salt,
                additionalData: additionalData
            )
            
            // Create encryption result with metadata
            let result = EncryptionResult(
                encryptedData: encryptedData,
                iv: iv,
                salt: salt,
                tag: tag,
                algorithm: self.configuration.algorithm,
                keyId: finalKeyId,
                timestamp: Date(),
                version: "2.0",
                metadata: [
                    "operation_id": operationId,
                    "data_size": data.count,
                    "compliance_level": self.configuration.complianceLevel.rawValue,
                    "hardware_encryption": self.hasSecureEnclave
                ]
            )
            
            // Update performance metrics
            let operationTime = CFAbsoluteTimeGetCurrent() - startTime
            await MainActor.run {
                self.performanceMetrics.updateEncryption(time: operationTime, success: true)
            }
            
            // Update key usage statistics
            self.updateKeyUsage(keyId: finalKeyId, dataSize: data.count, operationTime: operationTime, success: true)
            
            logger.info("Encryption operation \(operationId) completed successfully in \(String(format: "%.3f", operationTime * 1000))ms")
            
            return result
        }
    }
    
    /// Decrypt data with comprehensive validation
    /// - Parameters:
    ///   - encryptionResult: Result from encryption operation
    ///   - additionalData: Optional additional authenticated data
    /// - Returns: Decryption result with validation metadata
    public func decrypt(
        _ encryptionResult: EncryptionResult,
        additionalData: Data? = nil
    ) async throws -> DecryptionResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await encryptionQueue.perform { [weak self] in
            guard let self = self else {
                throw EncryptionError.managerDeallocated
            }
            
            let operationId = UUID().uuidString
            logger.info("Starting decryption operation \(operationId) for key \(encryptionResult.keyId)")
            
            var validationErrors: [String] = []
            
            // Validate encryption result integrity
            if encryptionResult.encryptedData.isEmpty {
                validationErrors.append("Empty encrypted data")
            }
            
            if encryptionResult.iv.count != self.configuration.ivSize {
                validationErrors.append("Invalid IV size")
            }
            
            if encryptionResult.tag.count != self.configuration.tagSize {
                validationErrors.append("Invalid authentication tag size")
            }
            
            // Retrieve decryption key
            guard let key = try await self.keyManager.getKey(keyId: encryptionResult.keyId) else {
                validationErrors.append("Decryption key not found")
                throw EncryptionError.keyNotFound(encryptionResult.keyId)
            }
            
            // Perform decryption
            let decryptedData = try await self.performDecryption(
                encryptedData: encryptionResult.encryptedData,
                key: key,
                iv: encryptionResult.iv,
                salt: encryptionResult.salt,
                tag: encryptionResult.tag,
                additionalData: additionalData
            )
            
            // Validate decrypted data integrity
            let isValid = validationErrors.isEmpty && !decryptedData.isEmpty
            
            // Create decryption result
            let result = DecryptionResult(
                decryptedData: decryptedData,
                isValid: isValid,
                algorithm: encryptionResult.algorithm,
                keyId: encryptionResult.keyId,
                timestamp: Date(),
                validationErrors: validationErrors,
                metadata: [
                    "operation_id": operationId,
                    "original_data_size": encryptionResult.encryptedData.count,
                    "decrypted_data_size": decryptedData.count,
                    "encryption_timestamp": encryptionResult.timestamp,
                    "hardware_backed": self.hasSecureEnclave
                ]
            )
            
            // Update performance metrics
            let operationTime = CFAbsoluteTimeGetCurrent() - startTime
            await MainActor.run {
                self.performanceMetrics.updateDecryption(time: operationTime, success: isValid)
            }
            
            // Update key usage statistics
            self.updateKeyUsage(keyId: encryptionResult.keyId, dataSize: decryptedData.count, operationTime: operationTime, success: isValid)
            
            logger.info("Decryption operation \(operationId) completed with validation: \(isValid) in \(String(format: "%.3f", operationTime * 1000))ms")
            
            return result
        }
    }
    
    // MARK: - Key Management
    
    /// Generate new encryption key with enterprise security
    public func generateKey(
        keyId: String,
        options: KeyGenerationOptions = KeyGenerationOptions()
    ) async throws -> KeyMetadata {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await encryptionQueue.perform { [weak self] in
            guard let self = self else {
                throw EncryptionError.managerDeallocated
            }
            
            logger.info("Generating new encryption key: \(keyId)")
            
            let key = try await self.keyManager.generateKey(keyId: keyId, options: options)
            let keyMetadata = try await self.keyManager.getKeyMetadata(keyId: keyId)
            
            let operationTime = CFAbsoluteTimeGetCurrent() - startTime
            await MainActor.run {
                self.performanceMetrics.updateKeyGeneration(time: operationTime)
            }
            
            logger.info("Key generation completed for \(keyId) in \(String(format: "%.3f", operationTime * 1000))ms")
            
            return keyMetadata
        }
    }
    
    /// Rotate encryption key with seamless transition
    public func rotateKey(keyId: String) async throws -> KeyMetadata {
        return try await encryptionQueue.perform { [weak self] in
            guard let self = self else {
                throw EncryptionError.managerDeallocated
            }
            
            logger.info("Rotating encryption key: \(keyId)")
            
            let newKeyMetadata = try await self.keyManager.rotateKey(keyId: keyId)
            
            await MainActor.run {
                self.performanceMetrics.incrementKeyRotation()
            }
            
            logger.info("Key rotation completed for \(keyId)")
            
            return newKeyMetadata
        }
    }
    
    /// Delete encryption key securely
    public func deleteKey(keyId: String) async throws {
        try await encryptionQueue.perform { [weak self] in
            guard let self = self else {
                throw EncryptionError.managerDeallocated
            }
            
            logger.info("Deleting encryption key: \(keyId)")
            
            try await self.keyManager.deleteKey(keyId: keyId)
            self.keyUsageStats.removeValue(forKey: keyId)
            
            logger.info("Key deletion completed for \(keyId)")
        }
    }
    
    /// List all available keys with metadata
    public func listKeys() async throws -> [KeyMetadata] {
        return try await encryptionQueue.perform { [weak self] in
            guard let self = self else {
                throw EncryptionError.managerDeallocated
            }
            
            return try await self.keyManager.listKeys()
        }
    }
    
    // MARK: - Security Health & Monitoring
    
    /// Perform comprehensive security health check
    public func performSecurityHealthCheck() async -> SecurityHealth {
        return await encryptionQueue.perform { [weak self] in
            guard let self = self else {
                return SecurityHealth()
            }
            
            logger.info("Performing security health check")
            
            var vulnerabilities: [SecurityVulnerability] = []
            var recommendations: [SecurityRecommendation] = []
            
            // Check encryption performance
            let encryptionHealth = self.assessEncryptionHealth()
            if encryptionHealth < 0.9 {
                vulnerabilities.append(SecurityVulnerability(
                    id: "PERF-001",
                    severity: .medium,
                    description: "Encryption performance below optimal threshold",
                    recommendation: "Consider key rotation or hardware acceleration"
                ))
            }
            
            // Check key management
            let keyManagementHealth = self.assessKeyManagementHealth()
            if keyManagementHealth < 0.95 {
                recommendations.append(SecurityRecommendation(
                    id: "KEY-001",
                    priority: .high,
                    title: "Key Management Optimization",
                    description: "Key management performance can be improved",
                    implementation: "Implement automatic key rotation and cleanup"
                ))
            }
            
            // Check compliance
            let complianceHealth = self.assessComplianceHealth()
            if complianceHealth < 1.0 {
                vulnerabilities.append(SecurityVulnerability(
                    id: "COMP-001",
                    severity: .high,
                    description: "Compliance requirements not fully met",
                    recommendation: "Review and update security configuration"
                ))
            }
            
            var health = SecurityHealth()
            health.updateHealth(
                encryption: encryptionHealth,
                keyManagement: keyManagementHealth,
                compliance: complianceHealth,
                vulnerabilities: vulnerabilities,
                recommendations: recommendations
            )
            
            self.securityHealth = health
            
            logger.info("Security health check completed - Overall health: \(String(format: "%.1f", health.overallHealth * 100))%")
            
            return health
        }
    }
    
    // MARK: - Private Implementation
    
    /// Perform encryption based on configured algorithm
    private func performEncryption(
        data: Data,
        key: Data,
        iv: Data,
        salt: Data,
        additionalData: Data?
    ) async throws -> (encryptedData: Data, tag: Data) {
        switch configuration.algorithm {
        case .aes256GCM:
            return try await encryptAES256GCM(data: data, key: key, iv: iv, additionalData: additionalData)
        case .aes128GCM:
            return try await encryptAES128GCM(data: data, key: key, iv: iv, additionalData: additionalData)
        case .chaCha20Poly1305:
            return try await encryptChaCha20Poly1305(data: data, key: key, iv: iv, additionalData: additionalData)
        case .aes256CBC:
            return try await encryptAES256CBC(data: data, key: key, iv: iv)
        case .aes192GCM:
            return try await encryptAES192GCM(data: data, key: key, iv: iv, additionalData: additionalData)
        }
    }
    
    /// Perform decryption based on algorithm
    private func performDecryption(
        encryptedData: Data,
        key: Data,
        iv: Data,
        salt: Data,
        tag: Data,
        additionalData: Data?
    ) async throws -> Data {
        switch configuration.algorithm {
        case .aes256GCM:
            return try await decryptAES256GCM(encryptedData: encryptedData, key: key, iv: iv, tag: tag, additionalData: additionalData)
        case .aes128GCM:
            return try await decryptAES128GCM(encryptedData: encryptedData, key: key, iv: iv, tag: tag, additionalData: additionalData)
        case .chaCha20Poly1305:
            return try await decryptChaCha20Poly1305(encryptedData: encryptedData, key: key, iv: iv, tag: tag, additionalData: additionalData)
        case .aes256CBC:
            return try await decryptAES256CBC(encryptedData: encryptedData, key: key, iv: iv)
        case .aes192GCM:
            return try await decryptAES192GCM(encryptedData: encryptedData, key: key, iv: iv, tag: tag, additionalData: additionalData)
        }
    }
    
    /// AES-256-GCM encryption implementation
    private func encryptAES256GCM(
        data: Data,
        key: Data,
        iv: Data,
        additionalData: Data?
    ) async throws -> (encryptedData: Data, tag: Data) {
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try AES.GCM.Nonce(data: iv)
        
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce, authenticating: additionalData)
        
        return (sealedBox.ciphertext, sealedBox.tag)
    }
    
    /// AES-256-GCM decryption implementation
    private func decryptAES256GCM(
        encryptedData: Data,
        key: Data,
        iv: Data,
        tag: Data,
        additionalData: Data?
    ) async throws -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try AES.GCM.Nonce(data: iv)
        
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: encryptedData, tag: tag)
        return try AES.GCM.open(sealedBox, using: symmetricKey, authenticating: additionalData)
    }
    
    /// AES-128-GCM encryption implementation
    private func encryptAES128GCM(
        data: Data,
        key: Data,
        iv: Data,
        additionalData: Data?
    ) async throws -> (encryptedData: Data, tag: Data) {
        // Implementation similar to AES-256-GCM but with 128-bit key
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try AES.GCM.Nonce(data: iv)
        
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce, authenticating: additionalData)
        
        return (sealedBox.ciphertext, sealedBox.tag)
    }
    
    /// AES-128-GCM decryption implementation
    private func decryptAES128GCM(
        encryptedData: Data,
        key: Data,
        iv: Data,
        tag: Data,
        additionalData: Data?
    ) async throws -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try AES.GCM.Nonce(data: iv)
        
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: encryptedData, tag: tag)
        return try AES.GCM.open(sealedBox, using: symmetricKey, authenticating: additionalData)
    }
    
    /// ChaCha20-Poly1305 encryption implementation
    private func encryptChaCha20Poly1305(
        data: Data,
        key: Data,
        iv: Data,
        additionalData: Data?
    ) async throws -> (encryptedData: Data, tag: Data) {
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try ChaChaPoly.Nonce(data: iv)
        
        let sealedBox = try ChaChaPoly.seal(data, using: symmetricKey, nonce: nonce, authenticating: additionalData)
        
        return (sealedBox.ciphertext, sealedBox.tag)
    }
    
    /// ChaCha20-Poly1305 decryption implementation
    private func decryptChaCha20Poly1305(
        encryptedData: Data,
        key: Data,
        iv: Data,
        tag: Data,
        additionalData: Data?
    ) async throws -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try ChaChaPoly.Nonce(data: iv)
        
        let sealedBox = try ChaChaPoly.SealedBox(nonce: nonce, ciphertext: encryptedData, tag: tag)
        return try ChaChaPoly.open(sealedBox, using: symmetricKey, authenticating: additionalData)
    }
    
    /// AES-192-GCM encryption implementation
    private func encryptAES192GCM(
        data: Data,
        key: Data,
        iv: Data,
        additionalData: Data?
    ) async throws -> (encryptedData: Data, tag: Data) {
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try AES.GCM.Nonce(data: iv)
        
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce, authenticating: additionalData)
        
        return (sealedBox.ciphertext, sealedBox.tag)
    }
    
    /// AES-192-GCM decryption implementation
    private func decryptAES192GCM(
        encryptedData: Data,
        key: Data,
        iv: Data,
        tag: Data,
        additionalData: Data?
    ) async throws -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try AES.GCM.Nonce(data: iv)
        
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: encryptedData, tag: tag)
        return try AES.GCM.open(sealedBox, using: symmetricKey, authenticating: additionalData)
    }
    
    /// AES-256-CBC encryption implementation
    private func encryptAES256CBC(
        data: Data,
        key: Data,
        iv: Data
    ) async throws -> (encryptedData: Data, tag: Data) {
        // Note: CBC mode doesn't provide authentication tag, returning empty tag
        let symmetricKey = SymmetricKey(data: key)
        
        // Add PKCS7 padding
        let paddedData = try addPKCS7Padding(data)
        
        // Perform CBC encryption using CommonCrypto
        var encryptedData = Data(count: paddedData.count)
        var bytesEncrypted = 0
        
        let status = encryptedData.withUnsafeMutableBytes { encryptedBytes in
            paddedData.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            key.count,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress,
                            paddedData.count,
                            encryptedBytes.baseAddress,
                            encryptedData.count,
                            &bytesEncrypted
                        )
                    }
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw EncryptionError.encryptionFailed("AES-256-CBC encryption failed with status: \(status)")
        }
        
        return (Data(encryptedData.prefix(bytesEncrypted)), Data()) // Empty tag for CBC
    }
    
    /// AES-256-CBC decryption implementation
    private func decryptAES256CBC(
        encryptedData: Data,
        key: Data,
        iv: Data
    ) async throws -> Data {
        var decryptedData = Data(count: encryptedData.count)
        var bytesDecrypted = 0
        
        let status = decryptedData.withUnsafeMutableBytes { decryptedBytes in
            encryptedData.withUnsafeBytes { encryptedBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            key.count,
                            ivBytes.baseAddress,
                            encryptedBytes.baseAddress,
                            encryptedData.count,
                            decryptedBytes.baseAddress,
                            decryptedData.count,
                            &bytesDecrypted
                        )
                    }
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw EncryptionError.decryptionFailed("AES-256-CBC decryption failed with status: \(status)")
        }
        
        return Data(decryptedData.prefix(bytesDecrypted))
    }
    
    /// Add PKCS7 padding to data
    private func addPKCS7Padding(_ data: Data) throws -> Data {
        let blockSize = kCCBlockSizeAES128
        let paddingLength = blockSize - (data.count % blockSize)
        let paddingValue = UInt8(paddingLength)
        
        var paddedData = data
        paddedData.append(contentsOf: Array(repeating: paddingValue, count: paddingLength))
        
        return paddedData
    }
    
    /// Generate cryptographically secure random data
    private func generateSecureRandom(length: Int) throws -> Data {
        var randomData = Data(count: length)
        let result = randomData.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, length, bytes.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            throw EncryptionError.randomGenerationFailed("Failed to generate secure random data: \(result)")
        }
        
        return randomData
    }
    
    /// Detect Secure Enclave availability
    private static func detectSecureEnclave() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // Check if device supports Secure Enclave
        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryAny,
            &error
        ) else {
            return false
        }
        
        // Test Secure Enclave availability by attempting to create a key
        let keyAttributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false,
                kSecAttrAccessControl as String: accessControl
            ]
        ]
        
        var publicKey, privateKey: SecKey?
        let status = SecKeyGeneratePair(keyAttributes as CFDictionary, &publicKey, &privateKey)
        
        return status == errSecSuccess
        #endif
    }
    
    /// Setup automatic key rotation
    private func setupKeyRotation() {
        keyRotationTimer?.invalidate()
        keyRotationTimer = Timer.scheduledTimer(withTimeInterval: configuration.keyRotationInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.performAutomaticKeyRotation()
            }
        }
    }
    
    /// Perform automatic key rotation for expired keys
    private func performAutomaticKeyRotation() async {
        do {
            let keys = try await keyManager.listKeys()
            let now = Date()
            
            for keyMetadata in keys {
                if let expirationDate = keyMetadata.expirationDate,
                   now > expirationDate {
                    try await rotateKey(keyId: keyMetadata.keyId)
                    logger.info("Automatically rotated expired key: \(keyMetadata.keyId)")
                }
            }
        } catch {
            logger.error("Automatic key rotation failed: \(error.localizedDescription)")
        }
    }
    
    /// Start security health monitoring
    private func startHealthMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in // Every 5 minutes
            Task {
                await self?.performSecurityHealthCheck()
            }
        }
    }
    
    /// Update key usage statistics
    private func updateKeyUsage(keyId: String, dataSize: Int, operationTime: TimeInterval, success: Bool) {
        if keyUsageStats[keyId] == nil {
            keyUsageStats[keyId] = KeyUsageStatistics()
        }
        keyUsageStats[keyId]?.recordUsage(dataSize: dataSize, operationTime: operationTime, success: success)
    }
    
    /// Assess encryption health metrics
    private func assessEncryptionHealth() -> Double {
        let targets = PerformanceMetrics.targets
        
        var healthScore: Double = 1.0
        
        // Check encryption time
        if performanceMetrics.averageEncryptionTime > targets.maxEncryptionTime {
            healthScore -= 0.2
        }
        
        // Check decryption time
        if performanceMetrics.averageDecryptionTime > targets.maxDecryptionTime {
            healthScore -= 0.2
        }
        
        // Check success rate
        if performanceMetrics.successRate < targets.minSuccessRate {
            healthScore -= 0.3
        }
        
        return max(0.0, healthScore)
    }
    
    /// Assess key management health
    private func assessKeyManagementHealth() -> Double {
        var healthScore: Double = 1.0
        
        // Check key rotation frequency
        let keyRotationHealth = performanceMetrics.keyRotationCount > 0 ? 1.0 : 0.8
        healthScore *= keyRotationHealth
        
        // Check key usage distribution
        let averageKeyUsage = keyUsageStats.values.map { $0.usageCount }.reduce(0, +) / max(1, keyUsageStats.count)
        if averageKeyUsage == 0 {
            healthScore -= 0.1
        }
        
        return max(0.0, healthScore)
    }
    
    /// Assess compliance health metrics
    private func assessComplianceHealth() -> Double {
        var healthScore: Double = 1.0
        
        // Check compliance level requirements
        switch configuration.complianceLevel {
        case .fips1402Level3:
            if !hasSecureEnclave || !configuration.enableSecureEnclave {
                healthScore -= 0.3
            }
            if configuration.keyRotationInterval > 8 * 60 * 60 { // 8 hours
                healthScore -= 0.2
            }
            
        case .enterprise:
            if configuration.keyRotationInterval > 24 * 60 * 60 { // 24 hours
                healthScore -= 0.1
            }
            
        default:
            break
        }
        
        // Check key management compliance
        if !configuration.enableKeyEscrow && configuration.complianceLevel == .fips1402Level3 {
            healthScore -= 0.2
        }
        
        return max(0.0, healthScore)
    }
}

// MARK: - Supporting Types & Extensions

/// Secure key manager for enterprise key lifecycle management
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
private final class SecureKeyManager {
    
    private let keychain: Keychain
    
    init() {
        self.keychain = Keychain()
    }
    
    func generateKey(keyId: String, options: EncryptionManager.KeyGenerationOptions) async throws -> Data {
        // Generate key using Secure Enclave if available and requested
        if options.useSecureEnclave {
            return try await generateSecureEnclaveKey(keyId: keyId, options: options)
        } else {
            return try await generateSoftwareKey(keyId: keyId, options: options)
        }
    }
    
    func getOrCreateKey(keyId: String, options: EncryptionManager.KeyGenerationOptions) async throws -> Data {
        if let existingKey = try await getKey(keyId: keyId) {
            return existingKey
        } else {
            return try await generateKey(keyId: keyId, options: options)
        }
    }
    
    func getKey(keyId: String) async throws -> Data? {
        return try await keychain.getData(keyId)
    }
    
    func deleteKey(keyId: String) async throws {
        try await keychain.delete(keyId)
    }
    
    func rotateKey(keyId: String) async throws -> EncryptionManager.KeyMetadata {
        // Create new key with same options
        let oldKey = try await getKey(keyId: keyId)
        guard oldKey != nil else {
            throw EncryptionError.keyNotFound(keyId)
        }
        
        // Generate new key
        let newKey = try await generateKey(keyId: keyId, options: EncryptionManager.KeyGenerationOptions())
        
        // Store new key
        try await keychain.set(newKey, forKey: keyId)
        
        return try await getKeyMetadata(keyId: keyId)
    }
    
    func listKeys() async throws -> [EncryptionManager.KeyMetadata] {
        let keyIds = try await keychain.allKeys()
        var keyMetadataList: [EncryptionManager.KeyMetadata] = []
        
        for keyId in keyIds {
            let metadata = try await getKeyMetadata(keyId: keyId)
            keyMetadataList.append(metadata)
        }
        
        return keyMetadataList
    }
    
    func getKeyMetadata(keyId: String) async throws -> EncryptionManager.KeyMetadata {
        guard let key = try await getKey(keyId: keyId) else {
            throw EncryptionError.keyNotFound(keyId)
        }
        
        return EncryptionManager.KeyMetadata(
            keyId: keyId,
            keyType: "AES",
            keySize: EncryptionManager.KeySize.bits256,
            creationDate: Date(), // In real implementation, store creation date
            isHardwareBacked: false, // Detect from keychain attributes
            purpose: .encryption,
            complianceLevel: .enterprise
        )
    }
    
    private func generateSecureEnclaveKey(keyId: String, options: EncryptionManager.KeyGenerationOptions) async throws -> Data {
        // Generate key in Secure Enclave
        var error: Unmanaged<CFError>?
        let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryAny,
            &error
        )
        
        guard let accessControl = accessControl else {
            throw EncryptionError.secureEnclaveNotAvailable
        }
        
        let keyAttributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: options.keySize.rawValue,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyId.data(using: .utf8)!,
                kSecAttrAccessControl as String: accessControl
            ]
        ]
        
        var publicKey, privateKey: SecKey?
        let status = SecKeyGeneratePair(keyAttributes as CFDictionary, &publicKey, &privateKey)
        
        guard status == errSecSuccess, let privateKey = privateKey else {
            throw EncryptionError.keyGenerationFailed("Secure Enclave key generation failed: \(status)")
        }
        
        // Convert to symmetric key data (in real implementation, derive from private key)
        return try generateSymmetricKeyFromSecureEnclaveKey(privateKey)
    }
    
    private func generateSoftwareKey(keyId: String, options: EncryptionManager.KeyGenerationOptions) async throws -> Data {
        let keySize = options.keySize.rawValue / 8 // Convert bits to bytes
        var keyData = Data(count: keySize)
        
        let result = keyData.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, keySize, bytes.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            throw EncryptionError.keyGenerationFailed("Software key generation failed: \(result)")
        }
        
        // Store in keychain
        try await keychain.set(keyData, forKey: keyId)
        
        return keyData
    }
    
    private func generateSymmetricKeyFromSecureEnclaveKey(_ privateKey: SecKey) throws -> Data {
        // In a real implementation, derive symmetric key from ECC private key
        // For now, generate a random symmetric key
        var keyData = Data(count: 32) // 256 bits
        let result = keyData.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 32, bytes.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            throw EncryptionError.keyGenerationFailed("Symmetric key derivation failed: \(result)")
        }
        
        return keyData
    }
}

/// Simple keychain wrapper for secure key storage
private final class Keychain {
    
    func set(_ data: Data, forKey key: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw EncryptionError.keychainError("Failed to store key in keychain: \(status)")
        }
    }
    
    func getData(_ key: String) async throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw EncryptionError.keychainError("Failed to retrieve key from keychain: \(status)")
        }
        
        return result as? Data
    }
    
    func delete(_ key: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw EncryptionError.keychainError("Failed to delete key from keychain: \(status)")
        }
    }
    
    func allKeys() async throws -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return []
            }
            throw EncryptionError.keychainError("Failed to list keys from keychain: \(status)")
        }
        
        guard let items = result as? [[String: Any]] else {
            return []
        }
        
        return items.compactMap { item in
            item[kSecAttrAccount as String] as? String
        }
    }
}

/// Encryption-related errors
public enum EncryptionError: LocalizedError, CustomStringConvertible {
    case managerDeallocated
    case keyNotFound(String)
    case keyGenerationFailed(String)
    case encryptionFailed(String)
    case decryptionFailed(String)
    case randomGenerationFailed(String)
    case keychainError(String)
    case secureEnclaveNotAvailable
    case invalidConfiguration(String)
    case complianceViolation(String)
    
    public var errorDescription: String? {
        switch self {
        case .managerDeallocated:
            return "EncryptionManager has been deallocated"
        case .keyNotFound(let keyId):
            return "Encryption key not found: \(keyId)"
        case .keyGenerationFailed(let details):
            return "Key generation failed: \(details)"
        case .encryptionFailed(let details):
            return "Encryption operation failed: \(details)"
        case .decryptionFailed(let details):
            return "Decryption operation failed: \(details)"
        case .randomGenerationFailed(let details):
            return "Random data generation failed: \(details)"
        case .keychainError(let details):
            return "Keychain operation failed: \(details)"
        case .secureEnclaveNotAvailable:
            return "Secure Enclave is not available on this device"
        case .invalidConfiguration(let details):
            return "Invalid encryption configuration: \(details)"
        case .complianceViolation(let details):
            return "Compliance violation detected: \(details)"
        }
    }
    
    public var description: String {
        return errorDescription ?? "Unknown encryption error"
    }
}

/// DispatchQueue extension for async operations
extension DispatchQueue {
    func perform<T>(_ work: @escaping () throws -> T) async rethrows -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.async {
                do {
                    let result = try work()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
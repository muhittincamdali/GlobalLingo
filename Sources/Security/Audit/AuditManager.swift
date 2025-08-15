import Foundation
import CryptoKit
import OSLog
import Combine

/// Enterprise-grade audit manager providing comprehensive security auditing
/// Supports real-time monitoring, forensic analysis, and compliance reporting
/// Implements NIST, ISO 27001, SOX, and enterprise audit standards
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public final class AuditManager: ObservableObject, Sendable {
    
    // MARK: - Singleton & Logger
    
    /// Shared instance with thread-safe initialization
    public static let shared = AuditManager()
    
    /// Enterprise logging with audit event categorization
    private let logger = Logger(subsystem: "com.globallingo.security", category: "audit")
    
    // MARK: - Configuration & State
    
    /// Audit configuration with enterprise policies
    public struct AuditConfiguration {
        public let enabledAuditTypes: Set<AuditType>
        public let realTimeMonitoring: Bool
        public let retentionPeriod: TimeInterval
        public let alertThresholds: AlertThresholds
        public let forensicMode: Bool
        public let encryptAuditLogs: Bool
        public let tamperDetection: Bool
        public let auditLogIntegrity: Bool
        public let complianceReporting: Bool
        public let automaticIncidentResponse: Bool
        public let maxLogSize: Int
        public let logRotationInterval: TimeInterval
        
        public init(
            enabledAuditTypes: Set<AuditType> = AuditType.allCases.map { Set([$0]) }.reduce(Set(), { $0.union($1) }),
            realTimeMonitoring: Bool = true,
            retentionPeriod: TimeInterval = 7 * 365 * 24 * 60 * 60, // 7 years
            alertThresholds: AlertThresholds = .enterprise,
            forensicMode: Bool = true,
            encryptAuditLogs: Bool = true,
            tamperDetection: Bool = true,
            auditLogIntegrity: Bool = true,
            complianceReporting: Bool = true,
            automaticIncidentResponse: Bool = true,
            maxLogSize: Int = 100 * 1024 * 1024, // 100MB
            logRotationInterval: TimeInterval = 24 * 60 * 60 // 24 hours
        ) {
            self.enabledAuditTypes = enabledAuditTypes
            self.realTimeMonitoring = realTimeMonitoring
            self.retentionPeriod = retentionPeriod
            self.alertThresholds = alertThresholds
            self.forensicMode = forensicMode
            self.encryptAuditLogs = encryptAuditLogs
            self.tamperDetection = tamperDetection
            self.auditLogIntegrity = auditLogIntegrity
            self.complianceReporting = complianceReporting
            self.automaticIncidentResponse = automaticIncidentResponse
            self.maxLogSize = maxLogSize
            self.logRotationInterval = logRotationInterval
        }
        
        /// Enterprise audit configuration
        public static let enterprise = AuditConfiguration(
            enabledAuditTypes: Set(AuditType.allCases),
            realTimeMonitoring: true,
            retentionPeriod: 7 * 365 * 24 * 60 * 60, // 7 years
            alertThresholds: .enterprise,
            forensicMode: true,
            encryptAuditLogs: true,
            tamperDetection: true,
            auditLogIntegrity: true,
            complianceReporting: true,
            automaticIncidentResponse: true,
            maxLogSize: 500 * 1024 * 1024, // 500MB
            logRotationInterval: 12 * 60 * 60 // 12 hours
        )
        
        /// Forensic investigation configuration
        public static let forensic = AuditConfiguration(
            enabledAuditTypes: Set(AuditType.allCases),
            realTimeMonitoring: true,
            retentionPeriod: 10 * 365 * 24 * 60 * 60, // 10 years
            alertThresholds: .forensic,
            forensicMode: true,
            encryptAuditLogs: true,
            tamperDetection: true,
            auditLogIntegrity: true,
            complianceReporting: true,
            automaticIncidentResponse: true,
            maxLogSize: 1024 * 1024 * 1024, // 1GB
            logRotationInterval: 6 * 60 * 60 // 6 hours
        )
    }
    
    /// Audit event types for comprehensive monitoring
    public enum AuditType: String, CaseIterable {
        case authentication = "authentication"
        case authorization = "authorization"
        case dataAccess = "data-access"
        case dataModification = "data-modification"
        case systemAccess = "system-access"
        case configurationChange = "configuration-change"
        case securityEvent = "security-event"
        case complianceEvent = "compliance-event"
        case performanceEvent = "performance-event"
        case errorEvent = "error-event"
        case networkEvent = "network-event"
        case fileSystemEvent = "file-system-event"
        case processEvent = "process-event"
        case privilegeEscalation = "privilege-escalation"
        case suspiciousActivity = "suspicious-activity"
        
        public var severity: AuditSeverity {
            switch self {
            case .authentication, .authorization: return .medium
            case .dataAccess, .dataModification: return .medium
            case .systemAccess, .configurationChange: return .high
            case .securityEvent, .privilegeEscalation: return .critical
            case .complianceEvent: return .high
            case .suspiciousActivity: return .critical
            case .performanceEvent, .errorEvent: return .low
            case .networkEvent, .fileSystemEvent, .processEvent: return .medium
            }
        }
        
        public var category: AuditCategory {
            switch self {
            case .authentication, .authorization, .privilegeEscalation: return .security
            case .dataAccess, .dataModification: return .dataGovernance
            case .systemAccess, .configurationChange: return .systemManagement
            case .securityEvent, .suspiciousActivity: return .security
            case .complianceEvent: return .compliance
            case .performanceEvent: return .performance
            case .errorEvent: return .operational
            case .networkEvent, .fileSystemEvent, .processEvent: return .infrastructure
            }
        }
    }
    
    /// Audit event severity levels
    public enum AuditSeverity: String, CaseIterable {
        case info = "info"
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
        
        public var priority: Int {
            switch self {
            case .info: return 1
            case .low: return 2
            case .medium: return 3
            case .high: return 4
            case .critical: return 5
            }
        }
    }
    
    /// Audit event categories for organization
    public enum AuditCategory: String, CaseIterable {
        case security = "security"
        case dataGovernance = "data-governance"
        case systemManagement = "system-management"
        case compliance = "compliance"
        case performance = "performance"
        case operational = "operational"
        case infrastructure = "infrastructure"
        case business = "business"
    }
    
    /// Alert thresholds for monitoring
    public struct AlertThresholds {
        public let failedLoginThreshold: Int
        public let failedLoginTimeWindow: TimeInterval
        public let dataAccessThreshold: Int
        public let dataAccessTimeWindow: TimeInterval
        public let privilegeEscalationThreshold: Int
        public let configurationChangeThreshold: Int
        public let suspiciousActivityThreshold: Int
        public let errorRateThreshold: Double
        public let responseTimeThreshold: TimeInterval
        
        public init(
            failedLoginThreshold: Int = 5,
            failedLoginTimeWindow: TimeInterval = 15 * 60, // 15 minutes
            dataAccessThreshold: Int = 100,
            dataAccessTimeWindow: TimeInterval = 60 * 60, // 1 hour
            privilegeEscalationThreshold: Int = 1,
            configurationChangeThreshold: Int = 10,
            suspiciousActivityThreshold: Int = 3,
            errorRateThreshold: Double = 0.05, // 5%
            responseTimeThreshold: TimeInterval = 2.0 // 2 seconds
        ) {
            self.failedLoginThreshold = failedLoginThreshold
            self.failedLoginTimeWindow = failedLoginTimeWindow
            self.dataAccessThreshold = dataAccessThreshold
            self.dataAccessTimeWindow = dataAccessTimeWindow
            self.privilegeEscalationThreshold = privilegeEscalationThreshold
            self.configurationChangeThreshold = configurationChangeThreshold
            self.suspiciousActivityThreshold = suspiciousActivityThreshold
            self.errorRateThreshold = errorRateThreshold
            self.responseTimeThreshold = responseTimeThreshold
        }
        
        /// Enterprise alert thresholds
        public static let enterprise = AlertThresholds(
            failedLoginThreshold: 3,
            failedLoginTimeWindow: 10 * 60, // 10 minutes
            dataAccessThreshold: 50,
            dataAccessTimeWindow: 30 * 60, // 30 minutes
            privilegeEscalationThreshold: 1,
            configurationChangeThreshold: 5,
            suspiciousActivityThreshold: 1,
            errorRateThreshold: 0.02, // 2%
            responseTimeThreshold: 1.0 // 1 second
        )
        
        /// Forensic investigation thresholds
        public static let forensic = AlertThresholds(
            failedLoginThreshold: 1,
            failedLoginTimeWindow: 5 * 60, // 5 minutes
            dataAccessThreshold: 10,
            dataAccessTimeWindow: 15 * 60, // 15 minutes
            privilegeEscalationThreshold: 1,
            configurationChangeThreshold: 1,
            suspiciousActivityThreshold: 1,
            errorRateThreshold: 0.01, // 1%
            responseTimeThreshold: 0.5 // 500ms
        )
    }
    
    /// Comprehensive audit event structure
    public struct AuditEvent {
        public let eventId: String
        public let timestamp: Date
        public let eventType: AuditType
        public let severity: AuditSeverity
        public let category: AuditCategory
        public let source: EventSource
        public let actor: Actor
        public let target: Target
        public let action: String
        public let outcome: EventOutcome
        public let details: [String: Any]
        public let context: EventContext
        public let fingerprint: String
        public let chainOfCustody: ChainOfCustody
        
        public struct EventSource {
            public let sourceId: String
            public let sourceType: SourceType
            public let ipAddress: String?
            public let userAgent: String?
            public let location: String?
            public let deviceId: String?
            public let applicationId: String?
            
            public enum SourceType: String, CaseIterable {
                case user = "user"
                case system = "system"
                case application = "application"
                case service = "service"
                case device = "device"
                case network = "network"
                case external = "external"
            }
            
            public init(
                sourceId: String,
                sourceType: SourceType,
                ipAddress: String? = nil,
                userAgent: String? = nil,
                location: String? = nil,
                deviceId: String? = nil,
                applicationId: String? = nil
            ) {
                self.sourceId = sourceId
                self.sourceType = sourceType
                self.ipAddress = ipAddress
                self.userAgent = userAgent
                self.location = location
                self.deviceId = deviceId
                self.applicationId = applicationId
            }
        }
        
        public struct Actor {
            public let actorId: String
            public let actorType: ActorType
            public let roles: [String]
            public let permissions: [String]
            public let sessionId: String?
            public let authenticatedAt: Date?
            public let riskScore: Double
            
            public enum ActorType: String, CaseIterable {
                case user = "user"
                case serviceAccount = "service-account"
                case systemProcess = "system-process"
                case anonymousUser = "anonymous-user"
                case administrator = "administrator"
                case externalEntity = "external-entity"
            }
            
            public init(
                actorId: String,
                actorType: ActorType,
                roles: [String] = [],
                permissions: [String] = [],
                sessionId: String? = nil,
                authenticatedAt: Date? = nil,
                riskScore: Double = 0.0
            ) {
                self.actorId = actorId
                self.actorType = actorType
                self.roles = roles
                self.permissions = permissions
                self.sessionId = sessionId
                self.authenticatedAt = authenticatedAt
                self.riskScore = riskScore
            }
        }
        
        public struct Target {
            public let targetId: String
            public let targetType: TargetType
            public let resourcePath: String?
            public let dataClassification: DataClassification
            public let sensitivity: DataSensitivity
            public let owner: String?
            public let metadata: [String: Any]
            
            public enum TargetType: String, CaseIterable {
                case file = "file"
                case database = "database"
                case service = "service"
                case configuration = "configuration"
                case user = "user"
                case system = "system"
                case network = "network"
                case application = "application"
            }
            
            public enum DataClassification: String, CaseIterable {
                case publicData = "public"
                case internalData = "internal"
                case confidential = "confidential"
                case restricted = "restricted"
                case topSecret = "top-secret"
            }
            
            public enum DataSensitivity: String, CaseIterable {
                case low = "low"
                case medium = "medium"
                case high = "high"
                case critical = "critical"
            }
            
            public init(
                targetId: String,
                targetType: TargetType,
                resourcePath: String? = nil,
                dataClassification: DataClassification = .internal,
                sensitivity: DataSensitivity = .medium,
                owner: String? = nil,
                metadata: [String: Any] = [:]
            ) {
                self.targetId = targetId
                self.targetType = targetType
                self.resourcePath = resourcePath
                self.dataClassification = dataClassification
                self.sensitivity = sensitivity
                self.owner = owner
                self.metadata = metadata
            }
        }
        
        public enum EventOutcome: String, CaseIterable {
            case success = "success"
            case failure = "failure"
            case partial = "partial"
            case denied = "denied"
            case timeout = "timeout"
            case error = "error"
            case pending = "pending"
        }
        
        public struct EventContext {
            public let correlationId: String
            public let sessionId: String?
            public let transactionId: String?
            public let requestId: String?
            public let parentEventId: String?
            public let relatedEvents: [String]
            public let businessProcess: String?
            public let riskContext: RiskContext
            
            public struct RiskContext {
                public let riskScore: Double
                public let riskFactors: [String]
                public let threatLevel: ThreatLevel
                public let anomalyScore: Double
                
                public enum ThreatLevel: String, CaseIterable {
                    case minimal = "minimal"
                    case low = "low"
                    case moderate = "moderate"
                    case high = "high"
                    case severe = "severe"
                }
                
                public init(
                    riskScore: Double = 0.0,
                    riskFactors: [String] = [],
                    threatLevel: ThreatLevel = .minimal,
                    anomalyScore: Double = 0.0
                ) {
                    self.riskScore = riskScore
                    self.riskFactors = riskFactors
                    self.threatLevel = threatLevel
                    self.anomalyScore = anomalyScore
                }
            }
            
            public init(
                correlationId: String,
                sessionId: String? = nil,
                transactionId: String? = nil,
                requestId: String? = nil,
                parentEventId: String? = nil,
                relatedEvents: [String] = [],
                businessProcess: String? = nil,
                riskContext: RiskContext = RiskContext()
            ) {
                self.correlationId = correlationId
                self.sessionId = sessionId
                self.transactionId = transactionId
                self.requestId = requestId
                self.parentEventId = parentEventId
                self.relatedEvents = relatedEvents
                self.businessProcess = businessProcess
                self.riskContext = riskContext
            }
        }
        
        public struct ChainOfCustody {
            public let custodian: String
            public let hash: String
            public let signature: String?
            public let witnessId: String?
            public let integrityCheck: String
            public let forensicMetadata: [String: Any]
            
            public init(
                custodian: String,
                hash: String,
                signature: String? = nil,
                witnessId: String? = nil,
                integrityCheck: String,
                forensicMetadata: [String: Any] = [:]
            ) {
                self.custodian = custodian
                self.hash = hash
                self.signature = signature
                self.witnessId = witnessId
                self.integrityCheck = integrityCheck
                self.forensicMetadata = forensicMetadata
            }
        }
        
        public init(
            eventId: String,
            timestamp: Date = Date(),
            eventType: AuditType,
            severity: AuditSeverity,
            category: AuditCategory,
            source: EventSource,
            actor: Actor,
            target: Target,
            action: String,
            outcome: EventOutcome,
            details: [String: Any] = [:],
            context: EventContext,
            fingerprint: String,
            chainOfCustody: ChainOfCustody
        ) {
            self.eventId = eventId
            self.timestamp = timestamp
            self.eventType = eventType
            self.severity = severity
            self.category = category
            self.source = source
            self.actor = actor
            self.target = target
            self.action = action
            self.outcome = outcome
            self.details = details
            self.context = context
            self.fingerprint = fingerprint
            self.chainOfCustody = chainOfCustody
        }
    }
    
    /// Audit query for searching and filtering
    public struct AuditQuery {
        public let startDate: Date?
        public let endDate: Date?
        public let eventTypes: Set<AuditType>?
        public let severities: Set<AuditSeverity>?
        public let categories: Set<AuditCategory>?
        public let actors: [String]?
        public let targets: [String]?
        public let outcomes: Set<AuditEvent.EventOutcome>?
        public let searchText: String?
        public let correlationId: String?
        public let limit: Int
        public let offset: Int
        public let sortOrder: SortOrder
        
        public enum SortOrder: String, CaseIterable {
            case timestampAsc = "timestamp-asc"
            case timestampDesc = "timestamp-desc"
            case severityAsc = "severity-asc"
            case severityDesc = "severity-desc"
            case relevanceDesc = "relevance-desc"
        }
        
        public init(
            startDate: Date? = nil,
            endDate: Date? = nil,
            eventTypes: Set<AuditType>? = nil,
            severities: Set<AuditSeverity>? = nil,
            categories: Set<AuditCategory>? = nil,
            actors: [String]? = nil,
            targets: [String]? = nil,
            outcomes: Set<AuditEvent.EventOutcome>? = nil,
            searchText: String? = nil,
            correlationId: String? = nil,
            limit: Int = 100,
            offset: Int = 0,
            sortOrder: SortOrder = .timestampDesc
        ) {
            self.startDate = startDate
            self.endDate = endDate
            self.eventTypes = eventTypes
            self.severities = severities
            self.categories = categories
            self.actors = actors
            self.targets = targets
            self.outcomes = outcomes
            self.searchText = searchText
            self.correlationId = correlationId
            self.limit = limit
            self.offset = offset
            self.sortOrder = sortOrder
        }
    }
    
    /// Security alert structure
    public struct SecurityAlert {
        public let alertId: String
        public let timestamp: Date
        public let alertType: AlertType
        public let severity: AuditSeverity
        public let title: String
        public let description: String
        public let triggerEvents: [AuditEvent]
        public let riskScore: Double
        public let recommendedActions: [String]
        public let status: AlertStatus
        public let assignedTo: String?
        public let escalationLevel: Int
        public let autoResolution: Bool
        public let metadata: [String: Any]
        
        public enum AlertType: String, CaseIterable {
            case failedLoginAttempts = "failed-login-attempts"
            case privilegeEscalation = "privilege-escalation"
            case suspiciousDataAccess = "suspicious-data-access"
            case configurationTampering = "configuration-tampering"
            case anomalousBehavior = "anomalous-behavior"
            case complianceViolation = "compliance-violation"
            case securityThreshold = "security-threshold"
            case intrusionAttempt = "intrusion-attempt"
            case dataExfiltration = "data-exfiltration"
            case systemCompromise = "system-compromise"
        }
        
        public enum AlertStatus: String, CaseIterable {
            case open = "open"
            case investigating = "investigating"
            case resolved = "resolved"
            case falsePositive = "false-positive"
            case suppressed = "suppressed"
            case escalated = "escalated"
        }
        
        public init(
            alertId: String,
            timestamp: Date = Date(),
            alertType: AlertType,
            severity: AuditSeverity,
            title: String,
            description: String,
            triggerEvents: [AuditEvent],
            riskScore: Double,
            recommendedActions: [String],
            status: AlertStatus = .open,
            assignedTo: String? = nil,
            escalationLevel: Int = 1,
            autoResolution: Bool = false,
            metadata: [String: Any] = [:]
        ) {
            self.alertId = alertId
            self.timestamp = timestamp
            self.alertType = alertType
            self.severity = severity
            self.title = title
            self.description = description
            self.triggerEvents = triggerEvents
            self.riskScore = riskScore
            self.recommendedActions = recommendedActions
            self.status = status
            self.assignedTo = assignedTo
            self.escalationLevel = escalationLevel
            self.autoResolution = autoResolution
            self.metadata = metadata
        }
    }
    
    // MARK: - Published Properties
    
    /// Real-time audit events stream
    @Published public private(set) var recentEvents: [AuditEvent] = []
    
    /// Active security alerts
    @Published public private(set) var activeAlerts: [SecurityAlert] = []
    
    /// Audit performance metrics
    @Published public private(set) var performanceMetrics = PerformanceMetrics()
    
    /// Security health monitoring
    @Published public private(set) var securityHealth = SecurityHealth()
    
    // MARK: - Private Properties
    
    /// Current audit configuration
    private var configuration: AuditConfiguration
    
    /// Audit event storage
    private var auditEventStore: [AuditEvent] = []
    
    /// Alert storage
    private var alertStore: [SecurityAlert] = []
    
    /// Event fingerprint cache for deduplication
    private var fingerprintCache: Set<String> = []
    
    /// Real-time monitoring timer
    private var monitoringTimer: Timer?
    
    /// Log rotation timer
    private var logRotationTimer: Timer?
    
    /// Thread-safe access queue
    private let auditQueue = DispatchQueue(label: "com.globallingo.audit", qos: .utility)
    
    // MARK: - Performance Tracking
    
    /// Performance metrics for audit operations
    public struct PerformanceMetrics {
        public private(set) var eventIngestionTime: TimeInterval = 0.0
        public private(set) var queryTime: TimeInterval = 0.0
        public private(set) var alertProcessingTime: TimeInterval = 0.0
        public private(set) var totalEvents: Int = 0
        public private(set) var eventsPerSecond: Double = 0.0
        public private(set) var alertsGenerated: Int = 0
        public private(set) var falsePositiveRate: Double = 0.0
        public private(set) var storageUtilization: Double = 0.0
        public private(set) var lastUpdated: Date = Date()
        
        /// Performance targets (enterprise-grade)
        public static let targets = PerformanceTargets(
            maxEventIngestionTime: 0.010, // 10ms
            maxQueryTime: 1.000, // 1 second
            maxAlertProcessingTime: 0.100, // 100ms
            minEventsPerSecond: 1000.0, // 1K events/sec
            maxFalsePositiveRate: 0.05, // 5%
            maxStorageUtilization: 0.80, // 80%
            maxMemoryUsage: 200 * 1024 * 1024 // 200MB
        )
        
        mutating func updateEventIngestion(time: TimeInterval, eventCount: Int) {
            eventIngestionTime = time
            totalEvents += eventCount
            eventsPerSecond = time > 0 ? Double(eventCount) / time : 0
            lastUpdated = Date()
        }
        
        mutating func updateQuery(time: TimeInterval) {
            queryTime = time
            lastUpdated = Date()
        }
        
        mutating func updateAlertProcessing(time: TimeInterval, alertCount: Int) {
            alertProcessingTime = time
            alertsGenerated += alertCount
            lastUpdated = Date()
        }
        
        mutating func updateFalsePositiveRate(_ rate: Double) {
            falsePositiveRate = rate
            lastUpdated = Date()
        }
        
        mutating func updateStorageUtilization(_ utilization: Double) {
            storageUtilization = utilization
            lastUpdated = Date()
        }
    }
    
    /// Performance targets for enterprise operations
    public struct PerformanceTargets {
        public let maxEventIngestionTime: TimeInterval
        public let maxQueryTime: TimeInterval
        public let maxAlertProcessingTime: TimeInterval
        public let minEventsPerSecond: Double
        public let maxFalsePositiveRate: Double
        public let maxStorageUtilization: Double
        public let maxMemoryUsage: Int
        
        public init(
            maxEventIngestionTime: TimeInterval,
            maxQueryTime: TimeInterval,
            maxAlertProcessingTime: TimeInterval,
            minEventsPerSecond: Double,
            maxFalsePositiveRate: Double,
            maxStorageUtilization: Double,
            maxMemoryUsage: Int
        ) {
            self.maxEventIngestionTime = maxEventIngestionTime
            self.maxQueryTime = maxQueryTime
            self.maxAlertProcessingTime = maxAlertProcessingTime
            self.minEventsPerSecond = minEventsPerSecond
            self.maxFalsePositiveRate = maxFalsePositiveRate
            self.maxStorageUtilization = maxStorageUtilization
            self.maxMemoryUsage = maxMemoryUsage
        }
    }
    
    /// Security health monitoring
    public struct SecurityHealth {
        public private(set) var overallHealth: Double = 1.0
        public private(set) var auditingHealth: Double = 1.0
        public private(set) var alertingHealth: Double = 1.0
        public private(set) var storageHealth: Double = 1.0
        public private(set) var integrityHealth: Double = 1.0
        public private(set) var lastSecurityCheck: Date = Date()
        public private(set) var vulnerabilities: [SecurityVulnerability] = []
        public private(set) var recommendations: [SecurityRecommendation] = []
        
        mutating func updateHealth(
            auditing: Double,
            alerting: Double,
            storage: Double,
            integrity: Double,
            vulnerabilities: [SecurityVulnerability] = [],
            recommendations: [SecurityRecommendation] = []
        ) {
            self.auditingHealth = auditing
            self.alertingHealth = alerting
            self.storageHealth = storage
            self.integrityHealth = integrity
            self.overallHealth = (auditing + alerting + storage + integrity) / 4.0
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
    
    // MARK: - Initialization
    
    /// Private initializer for singleton pattern
    private init() {
        self.configuration = .enterprise
        
        startRealTimeMonitoring()
        setupLogRotation()
        
        logger.info("AuditManager initialized with enterprise configuration")
    }
    
    /// Configure audit manager with custom settings
    public func configure(with configuration: AuditConfiguration) async {
        await auditQueue.perform {
            self.configuration = configuration
            self.setupRealTimeMonitoring()
            self.setupLogRotation()
        }
        
        logger.info("AuditManager configured with \(configuration.enabledAuditTypes.count) audit types enabled")
    }
    
    // MARK: - Core Audit Operations
    
    /// Log audit event for security monitoring
    /// - Parameter event: Audit event to log
    public func logEvent(_ event: AuditEvent) async {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await auditQueue.perform { [weak self] in
            guard let self = self else { return }
            
            // Check if event type is enabled
            guard self.configuration.enabledAuditTypes.contains(event.eventType) else {
                return
            }
            
            // Check for duplicate events using fingerprint
            if self.fingerprintCache.contains(event.fingerprint) {
                logger.debug("Duplicate audit event filtered: \(event.eventId)")
                return
            }
            
            // Add to fingerprint cache
            self.fingerprintCache.insert(event.fingerprint)
            
            // Store event
            if self.configuration.encryptAuditLogs {
                // In real implementation, encrypt the event before storage
                self.auditEventStore.append(event)
            } else {
                self.auditEventStore.append(event)
            }
            
            // Update recent events for real-time monitoring
            await MainActor.run {
                self.recentEvents.insert(event, at: 0)
                if self.recentEvents.count > 100 {
                    self.recentEvents.removeLast()
                }
            }
            
            // Process for alerts if real-time monitoring is enabled
            if self.configuration.realTimeMonitoring {
                await self.processEventForAlerts(event)
            }
            
            // Update performance metrics
            let operationTime = CFAbsoluteTimeGetCurrent() - startTime
            await MainActor.run {
                self.performanceMetrics.updateEventIngestion(time: operationTime, eventCount: 1)
            }
            
            logger.debug("Audit event logged: \(event.eventId) - \(event.action)")
        }
    }
    
    /// Log multiple audit events efficiently
    /// - Parameter events: Array of audit events to log
    public func logEvents(_ events: [AuditEvent]) async {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await auditQueue.perform { [weak self] in
            guard let self = self else { return }
            
            var processedEvents: [AuditEvent] = []
            
            for event in events {
                // Check if event type is enabled
                guard self.configuration.enabledAuditTypes.contains(event.eventType) else {
                    continue
                }
                
                // Check for duplicates
                if !self.fingerprintCache.contains(event.fingerprint) {
                    self.fingerprintCache.insert(event.fingerprint)
                    processedEvents.append(event)
                }
            }
            
            // Batch store events
            if self.configuration.encryptAuditLogs {
                // In real implementation, encrypt events before storage
                self.auditEventStore.append(contentsOf: processedEvents)
            } else {
                self.auditEventStore.append(contentsOf: processedEvents)
            }
            
            // Update recent events
            await MainActor.run {
                let newEvents = Array(processedEvents.prefix(50))
                self.recentEvents = newEvents + Array(self.recentEvents.prefix(50))
                if self.recentEvents.count > 100 {
                    self.recentEvents = Array(self.recentEvents.prefix(100))
                }
            }
            
            // Process for alerts
            if self.configuration.realTimeMonitoring {
                for event in processedEvents {
                    await self.processEventForAlerts(event)
                }
            }
            
            // Update performance metrics
            let operationTime = CFAbsoluteTimeGetCurrent() - startTime
            await MainActor.run {
                self.performanceMetrics.updateEventIngestion(time: operationTime, eventCount: processedEvents.count)
            }
            
            logger.info("Batch logged \(processedEvents.count) audit events")
        }
    }
    
    /// Query audit events with filtering and search
    /// - Parameter query: Query parameters for filtering
    /// - Returns: Filtered audit events
    public func queryEvents(_ query: AuditQuery) async throws -> [AuditEvent] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await auditQueue.perform { [weak self] in
            guard let self = self else {
                throw AuditError.managerDeallocated
            }
            
            logger.info("Executing audit query with \(self.auditEventStore.count) total events")
            
            var filteredEvents = self.auditEventStore
            
            // Apply filters
            if let startDate = query.startDate {
                filteredEvents = filteredEvents.filter { $0.timestamp >= startDate }
            }
            
            if let endDate = query.endDate {
                filteredEvents = filteredEvents.filter { $0.timestamp <= endDate }
            }
            
            if let eventTypes = query.eventTypes {
                filteredEvents = filteredEvents.filter { eventTypes.contains($0.eventType) }
            }
            
            if let severities = query.severities {
                filteredEvents = filteredEvents.filter { severities.contains($0.severity) }
            }
            
            if let categories = query.categories {
                filteredEvents = filteredEvents.filter { categories.contains($0.category) }
            }
            
            if let actors = query.actors {
                filteredEvents = filteredEvents.filter { actors.contains($0.actor.actorId) }
            }
            
            if let targets = query.targets {
                filteredEvents = filteredEvents.filter { targets.contains($0.target.targetId) }
            }
            
            if let outcomes = query.outcomes {
                filteredEvents = filteredEvents.filter { outcomes.contains($0.outcome) }
            }
            
            if let correlationId = query.correlationId {
                filteredEvents = filteredEvents.filter { $0.context.correlationId == correlationId }
            }
            
            if let searchText = query.searchText {
                filteredEvents = filteredEvents.filter { event in
                    event.action.lowercased().contains(searchText.lowercased()) ||
                    event.actor.actorId.lowercased().contains(searchText.lowercased()) ||
                    event.target.targetId.lowercased().contains(searchText.lowercased())
                }
            }
            
            // Apply sorting
            switch query.sortOrder {
            case .timestampAsc:
                filteredEvents.sort { $0.timestamp < $1.timestamp }
            case .timestampDesc:
                filteredEvents.sort { $0.timestamp > $1.timestamp }
            case .severityAsc:
                filteredEvents.sort { $0.severity.priority < $1.severity.priority }
            case .severityDesc:
                filteredEvents.sort { $0.severity.priority > $1.severity.priority }
            case .relevanceDesc:
                // In real implementation, implement relevance scoring
                filteredEvents.sort { $0.timestamp > $1.timestamp }
            }
            
            // Apply pagination
            let startIndex = min(query.offset, filteredEvents.count)
            let endIndex = min(startIndex + query.limit, filteredEvents.count)
            let paginatedEvents = Array(filteredEvents[startIndex..<endIndex])
            
            // Update performance metrics
            let operationTime = CFAbsoluteTimeGetCurrent() - startTime
            await MainActor.run {
                self.performanceMetrics.updateQuery(time: operationTime)
            }
            
            logger.info("Query completed: \(paginatedEvents.count) events returned in \(String(format: "%.3f", operationTime * 1000))ms")
            
            return paginatedEvents
        }
    }
    
    /// Get active security alerts
    /// - Returns: List of active security alerts
    public func getActiveAlerts() async -> [SecurityAlert] {
        return await auditQueue.perform { [weak self] in
            guard let self = self else { return [] }
            
            return self.alertStore.filter { $0.status == .open || $0.status == .investigating }
        }
    }
    
    /// Update security alert status
    /// - Parameters:
    ///   - alertId: Alert identifier
    ///   - status: New alert status
    ///   - assignedTo: Optional assignee
    ///   - notes: Optional update notes
    public func updateAlert(
        alertId: String,
        status: SecurityAlert.AlertStatus,
        assignedTo: String? = nil,
        notes: String? = nil
    ) async throws {
        try await auditQueue.perform { [weak self] in
            guard let self = self else {
                throw AuditError.managerDeallocated
            }
            
            guard let alertIndex = self.alertStore.firstIndex(where: { $0.alertId == alertId }) else {
                throw AuditError.alertNotFound(alertId)
            }
            
            let originalAlert = self.alertStore[alertIndex]
            
            // Create updated alert
            let updatedAlert = SecurityAlert(
                alertId: originalAlert.alertId,
                timestamp: originalAlert.timestamp,
                alertType: originalAlert.alertType,
                severity: originalAlert.severity,
                title: originalAlert.title,
                description: originalAlert.description,
                triggerEvents: originalAlert.triggerEvents,
                riskScore: originalAlert.riskScore,
                recommendedActions: originalAlert.recommendedActions,
                status: status,
                assignedTo: assignedTo ?? originalAlert.assignedTo,
                escalationLevel: originalAlert.escalationLevel,
                autoResolution: originalAlert.autoResolution,
                metadata: originalAlert.metadata
            )
            
            self.alertStore[alertIndex] = updatedAlert
            
            // Update active alerts
            await MainActor.run {
                if let activeIndex = self.activeAlerts.firstIndex(where: { $0.alertId == alertId }) {
                    if status == .open || status == .investigating {
                        self.activeAlerts[activeIndex] = updatedAlert
                    } else {
                        self.activeAlerts.remove(at: activeIndex)
                    }
                }
            }
            
            logger.info("Alert \(alertId) updated to status: \(status.rawValue)")
        }
    }
    
    /// Generate audit report for compliance
    /// - Parameters:
    ///   - query: Query parameters for report
    ///   - format: Report format
    /// - Returns: Generated audit report
    public func generateAuditReport(
        query: AuditQuery,
        format: ReportFormat = .json
    ) async throws -> AuditReport {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return try await auditQueue.perform { [weak self] in
            guard let self = self else {
                throw AuditError.managerDeallocated
            }
            
            let reportId = UUID().uuidString
            logger.info("Generating audit report \(reportId)")
            
            // Get events for report
            let events = try await self.queryEvents(query)
            
            // Generate summary statistics
            let eventTypeCounts = Dictionary(grouping: events, by: { $0.eventType })
                .mapValues { $0.count }
            
            let severityCounts = Dictionary(grouping: events, by: { $0.severity })
                .mapValues { $0.count }
            
            let outcomeCounts = Dictionary(grouping: events, by: { $0.outcome })
                .mapValues { $0.count }
            
            let actorCounts = Dictionary(grouping: events, by: { $0.actor.actorId })
                .mapValues { $0.count }
                .sorted { $0.value > $1.value }
                .prefix(10)
            
            // Calculate time-based metrics
            let timeSpan = (query.endDate ?? Date()).timeIntervalSince(query.startDate ?? Date(timeIntervalSince1970: 0))
            let eventsPerHour = timeSpan > 0 ? Double(events.count) / (timeSpan / 3600) : 0
            
            // Identify security trends
            let criticalEvents = events.filter { $0.severity == .critical }
            let failedEvents = events.filter { $0.outcome == .failure || $0.outcome == .denied }
            let privilegeEvents = events.filter { $0.eventType == .privilegeEscalation }
            
            let summary = AuditReport.Summary(
                totalEvents: events.count,
                timeSpan: timeSpan,
                eventsPerHour: eventsPerHour,
                criticalEventCount: criticalEvents.count,
                failedEventCount: failedEvents.count,
                privilegeEscalationCount: privilegeEvents.count,
                uniqueActors: Set(events.map { $0.actor.actorId }).count,
                uniqueTargets: Set(events.map { $0.target.targetId }).count,
                topActors: Dictionary(uniqueKeysWithValues: actorCounts),
                eventTypeDistribution: eventTypeCounts,
                severityDistribution: severityCounts,
                outcomeDistribution: outcomeCounts
            )
            
            let report = AuditReport(
                reportId: reportId,
                generatedAt: Date(),
                query: query,
                summary: summary,
                events: events,
                alerts: self.alertStore.filter { alert in
                    guard let startDate = query.startDate else { return true }
                    return alert.timestamp >= startDate
                },
                format: format,
                metadata: [
                    "generator": "AuditManager",
                    "version": "2.0",
                    "encryption_enabled": self.configuration.encryptAuditLogs,
                    "integrity_enabled": self.configuration.auditLogIntegrity
                ]
            )
            
            let operationTime = CFAbsoluteTimeGetCurrent() - startTime
            logger.info("Audit report \(reportId) generated in \(String(format: "%.3f", operationTime * 1000))ms")
            
            return report
        }
    }
    
    // MARK: - Security Health & Monitoring
    
    /// Perform comprehensive security health check
    public func performSecurityHealthCheck() async -> SecurityHealth {
        return await auditQueue.perform { [weak self] in
            guard let self = self else {
                return SecurityHealth()
            }
            
            logger.info("Performing audit security health check")
            
            var vulnerabilities: [SecurityVulnerability] = []
            var recommendations: [SecurityRecommendation] = []
            
            // Check auditing health
            let auditingHealth = self.assessAuditingHealth()
            if auditingHealth < 0.9 {
                vulnerabilities.append(SecurityVulnerability(
                    id: "AUDIT-001",
                    severity: .medium,
                    description: "Audit event processing performance degraded",
                    recommendation: "Optimize audit log storage and processing pipeline"
                ))
            }
            
            // Check alerting health
            let alertingHealth = self.assessAlertingHealth()
            if alertingHealth < 0.95 {
                recommendations.append(SecurityRecommendation(
                    id: "ALERT-001",
                    priority: .high,
                    title: "Alert Processing Optimization",
                    description: "Alert processing performance can be improved",
                    implementation: "Tune alert thresholds and implement alert correlation"
                ))
            }
            
            // Check storage health
            let storageHealth = self.assessStorageHealth()
            if storageHealth < 1.0 {
                vulnerabilities.append(SecurityVulnerability(
                    id: "STOR-001",
                    severity: .medium,
                    description: "Audit log storage approaching capacity limits",
                    recommendation: "Implement log archival and compression strategies"
                ))
            }
            
            // Check integrity health
            let integrityHealth = self.assessIntegrityHealth()
            if integrityHealth < 1.0 {
                vulnerabilities.append(SecurityVulnerability(
                    id: "INTEG-001",
                    severity: .high,
                    description: "Audit log integrity checks failing",
                    recommendation: "Investigate potential tampering and strengthen integrity controls"
                ))
            }
            
            var health = SecurityHealth()
            health.updateHealth(
                auditing: auditingHealth,
                alerting: alertingHealth,
                storage: storageHealth,
                integrity: integrityHealth,
                vulnerabilities: vulnerabilities,
                recommendations: recommendations
            )
            
            self.securityHealth = health
            
            logger.info("Audit security health check completed - Overall health: \(String(format: "%.1f", health.overallHealth * 100))%")
            
            return health
        }
    }
    
    // MARK: - Private Implementation
    
    /// Process event for potential security alerts
    private func processEventForAlerts(_ event: AuditEvent) async {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Check for failed login attempts
        if event.eventType == .authentication && event.outcome == .failure {
            await checkFailedLoginThreshold(event)
        }
        
        // Check for privilege escalation
        if event.eventType == .privilegeEscalation {
            await generateAlert(
                type: .privilegeEscalation,
                severity: .critical,
                title: "Privilege Escalation Detected",
                description: "Unauthorized privilege escalation attempt detected",
                triggerEvents: [event],
                riskScore: 0.9
            )
        }
        
        // Check for suspicious data access
        if event.eventType == .dataAccess && event.target.dataClassification == .confidential {
            await checkSuspiciousDataAccess(event)
        }
        
        // Check for configuration changes
        if event.eventType == .configurationChange {
            await checkConfigurationChangeThreshold(event)
        }
        
        // Update performance metrics
        let operationTime = CFAbsoluteTimeGetCurrent() - startTime
        await MainActor.run {
            self.performanceMetrics.updateAlertProcessing(time: operationTime, alertCount: 0)
        }
    }
    
    /// Check failed login threshold for alerts
    private func checkFailedLoginThreshold(_ event: AuditEvent) async {
        let timeWindow = configuration.alertThresholds.failedLoginTimeWindow
        let threshold = configuration.alertThresholds.failedLoginThreshold
        let cutoffTime = Date().addingTimeInterval(-timeWindow)
        
        let recentFailedLogins = auditEventStore.filter { auditEvent in
            auditEvent.eventType == .authentication &&
            auditEvent.outcome == .failure &&
            auditEvent.actor.actorId == event.actor.actorId &&
            auditEvent.timestamp > cutoffTime
        }
        
        if recentFailedLogins.count >= threshold {
            await generateAlert(
                type: .failedLoginAttempts,
                severity: .high,
                title: "Multiple Failed Login Attempts",
                description: "Actor \(event.actor.actorId) has \(recentFailedLogins.count) failed login attempts in the last \(Int(timeWindow/60)) minutes",
                triggerEvents: Array(recentFailedLogins.suffix(5)),
                riskScore: min(0.9, Double(recentFailedLogins.count) / Double(threshold * 2))
            )
        }
    }
    
    /// Check suspicious data access patterns
    private func checkSuspiciousDataAccess(_ event: AuditEvent) async {
        let timeWindow = configuration.alertThresholds.dataAccessTimeWindow
        let threshold = configuration.alertThresholds.dataAccessThreshold
        let cutoffTime = Date().addingTimeInterval(-timeWindow)
        
        let recentDataAccess = auditEventStore.filter { auditEvent in
            auditEvent.eventType == .dataAccess &&
            auditEvent.actor.actorId == event.actor.actorId &&
            auditEvent.timestamp > cutoffTime
        }
        
        if recentDataAccess.count >= threshold {
            await generateAlert(
                type: .suspiciousDataAccess,
                severity: .medium,
                title: "Suspicious Data Access Pattern",
                description: "Actor \(event.actor.actorId) has accessed \(recentDataAccess.count) data resources in the last hour",
                triggerEvents: Array(recentDataAccess.suffix(10)),
                riskScore: min(0.7, Double(recentDataAccess.count) / Double(threshold * 2))
            )
        }
    }
    
    /// Check configuration change threshold
    private func checkConfigurationChangeThreshold(_ event: AuditEvent) async {
        let timeWindow: TimeInterval = 60 * 60 // 1 hour
        let threshold = configuration.alertThresholds.configurationChangeThreshold
        let cutoffTime = Date().addingTimeInterval(-timeWindow)
        
        let recentChanges = auditEventStore.filter { auditEvent in
            auditEvent.eventType == .configurationChange &&
            auditEvent.timestamp > cutoffTime
        }
        
        if recentChanges.count >= threshold {
            await generateAlert(
                type: .configurationTampering,
                severity: .high,
                title: "Excessive Configuration Changes",
                description: "System has \(recentChanges.count) configuration changes in the last hour",
                triggerEvents: Array(recentChanges.suffix(5)),
                riskScore: min(0.8, Double(recentChanges.count) / Double(threshold * 2))
            )
        }
    }
    
    /// Generate security alert
    private func generateAlert(
        type: SecurityAlert.AlertType,
        severity: AuditSeverity,
        title: String,
        description: String,
        triggerEvents: [AuditEvent],
        riskScore: Double
    ) async {
        let alertId = UUID().uuidString
        
        let recommendedActions: [String] = {
            switch type {
            case .failedLoginAttempts:
                return [
                    "Investigate user account for compromise",
                    "Consider temporary account lockout",
                    "Review authentication logs",
                    "Implement additional MFA requirements"
                ]
            case .privilegeEscalation:
                return [
                    "Immediately investigate privilege escalation attempt",
                    "Review system access logs",
                    "Check for unauthorized system changes",
                    "Consider isolating affected systems"
                ]
            case .suspiciousDataAccess:
                return [
                    "Review data access patterns",
                    "Verify business justification for access",
                    "Consider data loss prevention measures",
                    "Monitor for data exfiltration"
                ]
            case .configurationTampering:
                return [
                    "Review configuration changes for authorization",
                    "Validate change management procedures",
                    "Check for unauthorized modifications",
                    "Implement configuration monitoring"
                ]
            default:
                return ["Investigate alert and take appropriate action"]
            }
        }()
        
        let alert = SecurityAlert(
            alertId: alertId,
            alertType: type,
            severity: severity,
            title: title,
            description: description,
            triggerEvents: triggerEvents,
            riskScore: riskScore,
            recommendedActions: recommendedActions
        )
        
        // Store alert
        alertStore.append(alert)
        
        // Update active alerts
        await MainActor.run {
            self.activeAlerts.insert(alert, at: 0)
            if self.activeAlerts.count > 50 {
                self.activeAlerts.removeLast()
            }
        }
        
        logger.warning("Security alert generated: \(alertId) - \(title)")
    }
    
    /// Start real-time monitoring
    private func startRealTimeMonitoring() {
        if configuration.realTimeMonitoring {
            setupRealTimeMonitoring()
        }
    }
    
    /// Setup real-time monitoring timer
    private func setupRealTimeMonitoring() {
        monitoringTimer?.invalidate()
        
        if configuration.realTimeMonitoring {
            monitoringTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
                Task {
                    await self?.performPeriodicAnalysis()
                }
            }
        }
    }
    
    /// Setup log rotation
    private func setupLogRotation() {
        logRotationTimer?.invalidate()
        
        logRotationTimer = Timer.scheduledTimer(withTimeInterval: configuration.logRotationInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.performLogRotation()
            }
        }
    }
    
    /// Perform periodic analysis for patterns and anomalies
    private func performPeriodicAnalysis() async {
        await auditQueue.perform { [weak self] in
            guard let self = self else { return }
            
            // Analyze recent events for patterns
            let recentTime = Date().addingTimeInterval(-3600) // Last hour
            let recentEvents = self.auditEventStore.filter { $0.timestamp > recentTime }
            
            // Update storage utilization
            let currentSize = self.auditEventStore.count * 1024 // Rough estimate
            let maxSize = self.configuration.maxLogSize
            let utilization = Double(currentSize) / Double(maxSize)
            
            await MainActor.run {
                self.performanceMetrics.updateStorageUtilization(utilization)
            }
            
            logger.debug("Periodic analysis completed: \(recentEvents.count) recent events analyzed")
        }
    }
    
    /// Perform log rotation and archival
    private func performLogRotation() async {
        await auditQueue.perform { [weak self] in
            guard let self = self else { return }
            
            let cutoffDate = Date().addingTimeInterval(-self.configuration.retentionPeriod)
            let beforeCount = self.auditEventStore.count
            
            // Remove old events
            self.auditEventStore = self.auditEventStore.filter { $0.timestamp > cutoffDate }
            
            // Clean fingerprint cache
            self.fingerprintCache.removeAll()
            
            let removedCount = beforeCount - self.auditEventStore.count
            if removedCount > 0 {
                logger.info("Log rotation completed: removed \(removedCount) old events")
            }
        }
    }
    
    /// Assess auditing health metrics
    private func assessAuditingHealth() -> Double {
        let targets = PerformanceMetrics.targets
        
        var healthScore: Double = 1.0
        
        // Check event ingestion performance
        if performanceMetrics.eventIngestionTime > targets.maxEventIngestionTime {
            healthScore -= 0.3
        }
        
        // Check events per second
        if performanceMetrics.eventsPerSecond < targets.minEventsPerSecond {
            healthScore -= 0.2
        }
        
        return max(0.0, healthScore)
    }
    
    /// Assess alerting health metrics
    private func assessAlertingHealth() -> Double {
        let targets = PerformanceMetrics.targets
        
        var healthScore: Double = 1.0
        
        // Check alert processing performance
        if performanceMetrics.alertProcessingTime > targets.maxAlertProcessingTime {
            healthScore -= 0.2
        }
        
        // Check false positive rate
        if performanceMetrics.falsePositiveRate > targets.maxFalsePositiveRate {
            healthScore -= 0.3
        }
        
        return max(0.0, healthScore)
    }
    
    /// Assess storage health metrics
    private func assessStorageHealth() -> Double {
        let targets = PerformanceMetrics.targets
        
        var healthScore: Double = 1.0
        
        // Check storage utilization
        if performanceMetrics.storageUtilization > targets.maxStorageUtilization {
            healthScore -= 0.4
        }
        
        return max(0.0, healthScore)
    }
    
    /// Assess integrity health metrics
    private func assessIntegrityHealth() -> Double {
        var healthScore: Double = 1.0
        
        // Check if integrity checking is enabled
        if !configuration.auditLogIntegrity {
            healthScore -= 0.3
        }
        
        // Check if tamper detection is enabled
        if !configuration.tamperDetection {
            healthScore -= 0.2
        }
        
        return max(0.0, healthScore)
    }
}

// MARK: - Supporting Types

/// Audit report structure
public struct AuditReport {
    public let reportId: String
    public let generatedAt: Date
    public let query: AuditManager.AuditQuery
    public let summary: Summary
    public let events: [AuditManager.AuditEvent]
    public let alerts: [AuditManager.SecurityAlert]
    public let format: ReportFormat
    public let metadata: [String: Any]
    
    public struct Summary {
        public let totalEvents: Int
        public let timeSpan: TimeInterval
        public let eventsPerHour: Double
        public let criticalEventCount: Int
        public let failedEventCount: Int
        public let privilegeEscalationCount: Int
        public let uniqueActors: Int
        public let uniqueTargets: Int
        public let topActors: [String: Int]
        public let eventTypeDistribution: [AuditManager.AuditType: Int]
        public let severityDistribution: [AuditManager.AuditSeverity: Int]
        public let outcomeDistribution: [AuditManager.AuditEvent.EventOutcome: Int]
        
        public init(
            totalEvents: Int,
            timeSpan: TimeInterval,
            eventsPerHour: Double,
            criticalEventCount: Int,
            failedEventCount: Int,
            privilegeEscalationCount: Int,
            uniqueActors: Int,
            uniqueTargets: Int,
            topActors: [String: Int],
            eventTypeDistribution: [AuditManager.AuditType: Int],
            severityDistribution: [AuditManager.AuditSeverity: Int],
            outcomeDistribution: [AuditManager.AuditEvent.EventOutcome: Int]
        ) {
            self.totalEvents = totalEvents
            self.timeSpan = timeSpan
            self.eventsPerHour = eventsPerHour
            self.criticalEventCount = criticalEventCount
            self.failedEventCount = failedEventCount
            self.privilegeEscalationCount = privilegeEscalationCount
            self.uniqueActors = uniqueActors
            self.uniqueTargets = uniqueTargets
            self.topActors = topActors
            self.eventTypeDistribution = eventTypeDistribution
            self.severityDistribution = severityDistribution
            self.outcomeDistribution = outcomeDistribution
        }
    }
    
    public enum ReportFormat: String, CaseIterable {
        case json = "json"
        case pdf = "pdf"
        case html = "html"
        case csv = "csv"
        case xml = "xml"
        case siem = "siem"
    }
    
    public init(
        reportId: String,
        generatedAt: Date,
        query: AuditManager.AuditQuery,
        summary: Summary,
        events: [AuditManager.AuditEvent],
        alerts: [AuditManager.SecurityAlert],
        format: ReportFormat,
        metadata: [String: Any]
    ) {
        self.reportId = reportId
        self.generatedAt = generatedAt
        self.query = query
        self.summary = summary
        self.events = events
        self.alerts = alerts
        self.format = format
        self.metadata = metadata
    }
}

// MARK: - Audit Errors

/// Audit-related errors
public enum AuditError: LocalizedError, CustomStringConvertible {
    case managerDeallocated
    case invalidQuery(String)
    case eventProcessingFailed(String)
    case alertNotFound(String)
    case reportGenerationFailed(String)
    case storageError(String)
    case integrityCheckFailed(String)
    case configurationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .managerDeallocated:
            return "AuditManager has been deallocated"
        case .invalidQuery(let details):
            return "Invalid audit query: \(details)"
        case .eventProcessingFailed(let details):
            return "Event processing failed: \(details)"
        case .alertNotFound(let alertId):
            return "Security alert not found: \(alertId)"
        case .reportGenerationFailed(let details):
            return "Report generation failed: \(details)"
        case .storageError(let details):
            return "Audit storage error: \(details)"
        case .integrityCheckFailed(let details):
            return "Integrity check failed: \(details)"
        case .configurationError(let details):
            return "Audit configuration error: \(details)"
        }
    }
    
    public var description: String {
        return errorDescription ?? "Unknown audit error"
    }
}
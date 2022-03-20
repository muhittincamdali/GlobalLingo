import Foundation
import CryptoKit
import Security

/// Protocol defining security manager operations
public protocol SecurityManagerProtocol {
    
    /// Encrypt data
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    func encrypt(_ data: Data, with key: String) throws -> Data
    
    /// Decrypt data
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    func decrypt(_ data: Data, with key: String) throws -> Data
    
    /// Generate secure random key
    /// - Parameter length: Key length in bytes
    /// - Returns: Generated key
    func generateSecureKey(length: Int) throws -> Data
    
    /// Hash data using SHA-256
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    func hash(_ data: Data) -> Data
    
    /// Store secure data in keychain
    /// - Parameters:
    ///   - data: Data to store
    ///   - key: Key for storage
    /// - Returns: True if successful
    func storeInKeychain(_ data: Data, for key: String) throws -> Bool
    
    /// Retrieve secure data from keychain
    /// - Parameter key: Key for retrieval
    /// - Returns: Retrieved data
    func retrieveFromKeychain(for key: String) throws -> Data
    
    /// Delete secure data from keychain
    /// - Parameter key: Key to delete
    /// - Returns: True if successful
    func deleteFromKeychain(for key: String) throws -> Bool
    
    /// Validate certificate pinning
    /// - Parameter host: Host to validate
    /// - Returns: True if valid
    func validateCertificatePinning(for host: String) -> Bool
}

/// Implementation of the security manager
public class SecurityManager: SecurityManagerProtocol {
    
    // MARK: - Properties
    
    private let keychainService: KeychainServiceProtocol
    private let certificatePinner: CertificatePinnerProtocol
    
    // MARK: - Initialization
    
    /// Initialize the security manager
    /// - Parameters:
    ///   - keychainService: Keychain service
    ///   - certificatePinner: Certificate pinner
    public init(
        keychainService: KeychainServiceProtocol,
        certificatePinner: CertificatePinnerProtocol
    ) {
        self.keychainService = keychainService
        self.certificatePinner = certificatePinner
    }
    
    // MARK: - SecurityManagerProtocol Implementation
    
    public func encrypt(_ data: Data, with key: String) throws -> Data {
        
        // Generate encryption key from string
        let keyData = Data(key.utf8)
        let hashedKey = SHA256.hash(data: keyData)
        let symmetricKey = SymmetricKey(data: hashedKey)
        
        // Encrypt data
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
        
        return sealedBox.combined ?? Data()
    }
    
    public func decrypt(_ data: Data, with key: String) throws -> Data {
        
        // Generate decryption key from string
        let keyData = Data(key.utf8)
        let hashedKey = SHA256.hash(data: keyData)
        let symmetricKey = SymmetricKey(data: hashedKey)
        
        // Decrypt data
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        
        return decryptedData
    }
    
    public func generateSecureKey(length: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        
        guard status == errSecSuccess else {
            throw SecurityError.keyGenerationFailed
        }
        
        return Data(bytes)
    }
    
    public func hash(_ data: Data) -> Data {
        let hashed = SHA256.hash(data: data)
        return Data(hashed)
    }
    
    public func storeInKeychain(_ data: Data, for key: String) throws -> Bool {
        return try keychainService.store(data: data, for: key)
    }
    
    public func retrieveFromKeychain(for key: String) throws -> Data {
        return try keychainService.retrieve(for: key)
    }
    
    public func deleteFromKeychain(for key: String) throws -> Bool {
        return try keychainService.delete(for: key)
    }
    
    public func validateCertificatePinning(for host: String) -> Bool {
        return certificatePinner.validate(for: host)
    }
}

// MARK: - Security Error

/// Errors that can occur during security operations
public enum SecurityError: Error, LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
    case keychainError(String)
    case certificatePinningFailed
    case invalidKey
    case invalidData
    
    public var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Data encryption failed"
        case .decryptionFailed:
            return "Data decryption failed"
        case .keyGenerationFailed:
            return "Secure key generation failed"
        case .keychainError(let message):
            return "Keychain error: \(message)"
        case .certificatePinningFailed:
            return "Certificate pinning validation failed"
        case .invalidKey:
            return "Invalid encryption key"
        case .invalidData:
            return "Invalid data for operation"
        }
    }
}

// MARK: - Keychain Service Protocol

/// Protocol for keychain operations
public protocol KeychainServiceProtocol {
    
    /// Store data in keychain
    /// - Parameters:
    ///   - data: Data to store
    ///   - key: Key for storage
    /// - Returns: True if successful
    func store(data: Data, for key: String) throws -> Bool
    
    /// Retrieve data from keychain
    /// - Parameter key: Key for retrieval
    /// - Returns: Retrieved data
    func retrieve(for key: String) throws -> Data
    
    /// Delete data from keychain
    /// - Parameter key: Key to delete
    /// - Returns: True if successful
    func delete(for key: String) throws -> Bool
    
    /// Check if key exists in keychain
    /// - Parameter key: Key to check
    /// - Returns: True if exists
    func exists(for key: String) -> Bool
}

// MARK: - Certificate Pinner Protocol

/// Protocol for certificate pinning operations
public protocol CertificatePinnerProtocol {
    
    /// Validate certificate pinning for host
    /// - Parameter host: Host to validate
    /// - Returns: True if valid
    func validate(for host: String) -> Bool
    
    /// Add certificate for pinning
    /// - Parameters:
    ///   - certificate: Certificate data
    ///   - host: Host for certificate
    /// - Returns: True if successful
    func addCertificate(_ certificate: Data, for host: String) -> Bool
    
    /// Remove certificate pinning for host
    /// - Parameter host: Host to remove
    /// - Returns: True if successful
    func removeCertificate(for host: String) -> Bool
}

// MARK: - Security Utilities

/// Utility functions for security operations
public struct SecurityUtilities {
    
    /// Generate a secure random string
    /// - Parameter length: Length of string
    /// - Returns: Random string
    public static func generateRandomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    /// Validate password strength
    /// - Parameter password: Password to validate
    /// - Returns: Password strength
    public static func validatePasswordStrength(_ password: String) -> PasswordStrength {
        var score = 0
        
        // Length check
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        
        // Character variety checks
        if password.range(of: "[a-z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil { score += 1 }
        
        switch score {
        case 0...2:
            return .weak
        case 3...4:
            return .medium
        case 5...6:
            return .strong
        default:
            return .veryStrong
        }
    }
}

// MARK: - Password Strength

/// Represents password strength levels
public enum PasswordStrength {
    case weak
    case medium
    case strong
    case veryStrong
    
    public var description: String {
        switch self {
        case .weak:
            return "Weak"
        case .medium:
            return "Medium"
        case .strong:
            return "Strong"
        case .veryStrong:
            return "Very Strong"
        }
    }
    
    public var color: String {
        switch self {
        case .weak:
            return "red"
        case .medium:
            return "orange"
        case .strong:
            return "yellow"
        case .veryStrong:
            return "green"
        }
    }
}

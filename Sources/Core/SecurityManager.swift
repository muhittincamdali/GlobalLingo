import Foundation
import Crypto
import Security

/// Security manager for GlobalLingo translation framework
/// Handles encryption, authentication, and secure data storage
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public class SecurityManager {
    
    // MARK: - Properties
    
    private var encryptionEnabled = true
    private var encryptionKey: SymmetricKey?
    
    // MARK: - Initialization
    
    public init() {
        setupEncryption()
    }
    
    // MARK: - Configuration
    
    /// Configure security manager
    /// - Parameter encryptionEnabled: Whether encryption is enabled
    public func configure(encryptionEnabled: Bool) {
        self.encryptionEnabled = encryptionEnabled
    }
    
    // MARK: - Encryption
    
    /// Encrypt data
    /// - Parameter data: Data to encrypt
    /// - Returns: Encrypted data
    public func encryptData(_ data: Data) throws -> Data {
        guard encryptionEnabled else { return data }
        
        guard let key = encryptionKey else {
            throw SecurityError.encryptionKeyNotAvailable
        }
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined!
        } catch {
            throw SecurityError.encryptionFailed(error)
        }
    }
    
    /// Decrypt data
    /// - Parameter encryptedData: Encrypted data to decrypt
    /// - Returns: Decrypted data
    public func decryptData(_ encryptedData: Data) throws -> Data {
        guard encryptionEnabled else { return encryptedData }
        
        guard let key = encryptionKey else {
            throw SecurityError.encryptionKeyNotAvailable
        }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            throw SecurityError.decryptionFailed(error)
        }
    }
    
    /// Encrypt string
    /// - Parameter string: String to encrypt
    /// - Returns: Encrypted string (base64 encoded)
    public func encryptString(_ string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw SecurityError.invalidInput
        }
        
        let encryptedData = try encryptData(data)
        return encryptedData.base64EncodedString()
    }
    
    /// Decrypt string
    /// - Parameter encryptedString: Encrypted string (base64 encoded)
    /// - Returns: Decrypted string
    public func decryptString(_ encryptedString: String) throws -> String {
        guard let encryptedData = Data(base64Encoded: encryptedString) else {
            throw SecurityError.invalidInput
        }
        
        let decryptedData = try decryptData(encryptedData)
        
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw SecurityError.invalidInput
        }
        
        return string
    }
    
    // MARK: - Secure Storage
    
    /// Store data securely
    /// - Parameters:
    ///   - data: Data to store
    ///   - key: Key for storage
    public func storeSecurely(_ data: Data, for key: String) throws {
        let encryptedData = try encryptData(data)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: encryptedData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: encryptedData
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            
            if updateStatus != errSecSuccess {
                throw SecurityError.storageFailed(updateStatus)
            }
        } else if status != errSecSuccess {
            throw SecurityError.storageFailed(status)
        }
    }
    
    /// Retrieve data securely
    /// - Parameter key: Key for retrieval
    /// - Returns: Stored data
    public func retrieveSecurely(for key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let encryptedData = result as? Data else {
            throw SecurityError.dataNotFound
        }
        
        return try decryptData(encryptedData)
    }
    
    /// Delete data securely
    /// - Parameter key: Key to delete
    public func deleteSecurely(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw SecurityError.deletionFailed(status)
        }
    }
    
    // MARK: - API Key Management
    
    /// Store API key securely
    /// - Parameter apiKey: API key to store
    public func storeAPIKey(_ apiKey: String) throws {
        guard let data = apiKey.data(using: .utf8) else {
            throw SecurityError.invalidInput
        }
        
        try storeSecurely(data, for: "api_key")
    }
    
    /// Retrieve API key securely
    /// - Returns: Stored API key
    public func retrieveAPIKey() throws -> String {
        let data = try retrieveSecurely(for: "api_key")
        
        guard let apiKey = String(data: data, encoding: .utf8) else {
            throw SecurityError.invalidInput
        }
        
        return apiKey
    }
    
    /// Validate API key
    /// - Parameter apiKey: API key to validate
    /// - Returns: Boolean indicating validity
    public func validateAPIKey(_ apiKey: String) -> Bool {
        // Basic validation - in a real implementation, this would check format and checksum
        return apiKey.count >= 32 && apiKey.contains("gl_")
    }
    
    // MARK: - Certificate Pinning
    
    /// Pin certificate for domain
    /// - Parameter domain: Domain to pin certificate for
    public func pinCertificate(for domain: String) {
        // In a real implementation, this would set up certificate pinning
        // For now, this is a placeholder
    }
    
    /// Validate certificate for domain
    /// - Parameter domain: Domain to validate certificate for
    /// - Returns: Boolean indicating validity
    public func validateCertificate(for domain: String) -> Bool {
        // In a real implementation, this would validate the certificate
        // For now, return true as placeholder
        return true
    }
    
    // MARK: - Biometric Authentication
    
    /// Check if biometric authentication is available
    /// - Returns: Boolean indicating availability
    public func isBiometricAuthenticationAvailable() -> Bool {
        // In a real implementation, this would check biometric availability
        // For now, return false as placeholder
        return false
    }
    
    /// Authenticate with biometrics
    /// - Returns: Boolean indicating success
    public func authenticateWithBiometrics() async throws -> Bool {
        // In a real implementation, this would perform biometric authentication
        // For now, throw error as placeholder
        throw SecurityError.biometricsNotAvailable
    }
    
    // MARK: - Input Validation
    
    /// Validate input for security
    /// - Parameter input: Input to validate
    /// - Returns: Boolean indicating validity
    public func validateInput(_ input: String) -> Bool {
        // Check for malicious content
        let maliciousPatterns = [
            "<script>",
            "javascript:",
            "data:text/html",
            "vbscript:",
            "onload=",
            "onerror=",
            "onclick="
        ]
        
        let lowercasedInput = input.lowercased()
        
        for pattern in maliciousPatterns {
            if lowercasedInput.contains(pattern) {
                return false
            }
        }
        
        return true
    }
    
    /// Sanitize input
    /// - Parameter input: Input to sanitize
    /// - Returns: Sanitized input
    public func sanitizeInput(_ input: String) -> String {
        // Remove potentially dangerous characters and patterns
        var sanitized = input
        
        // Remove script tags
        sanitized = sanitized.replacingOccurrences(of: "<script>", with: "", options: .caseInsensitive)
        sanitized = sanitized.replacingOccurrences(of: "</script>", with: "", options: .caseInsensitive)
        
        // Remove javascript protocol
        sanitized = sanitized.replacingOccurrences(of: "javascript:", with: "", options: .caseInsensitive)
        
        // Remove event handlers
        let eventHandlers = ["onload", "onerror", "onclick", "onmouseover", "onfocus"]
        for handler in eventHandlers {
            let pattern = "\(handler)\\s*="
            sanitized = sanitized.replacingOccurrences(of: pattern, with: "", options: [.caseInsensitive, .regularExpression])
        }
        
        return sanitized
    }
    
    // MARK: - Private Methods
    
    private func setupEncryption() {
        do {
            encryptionKey = try generateEncryptionKey()
        } catch {
            print("Failed to generate encryption key: \(error)")
        }
    }
    
    private func generateEncryptionKey() throws -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
}

// MARK: - Supporting Types

public enum SecurityError: LocalizedError {
    case encryptionKeyNotAvailable
    case encryptionFailed(Error)
    case decryptionFailed(Error)
    case storageFailed(OSStatus)
    case dataNotFound
    case deletionFailed(OSStatus)
    case invalidInput
    case biometricsNotAvailable
    case authenticationFailed
    
    public var errorDescription: String? {
        switch self {
        case .encryptionKeyNotAvailable:
            return "Encryption key is not available"
        case .encryptionFailed(let error):
            return "Encryption failed: \(error.localizedDescription)"
        case .decryptionFailed(let error):
            return "Decryption failed: \(error.localizedDescription)"
        case .storageFailed(let status):
            return "Storage failed with status: \(status)"
        case .dataNotFound:
            return "Data not found in secure storage"
        case .deletionFailed(let status):
            return "Deletion failed with status: \(status)"
        case .invalidInput:
            return "Invalid input data"
        case .biometricsNotAvailable:
            return "Biometric authentication is not available"
        case .authenticationFailed:
            return "Authentication failed"
        }
    }
}

public struct SecurityConfiguration {
    public let encryptionEnabled: Bool
    public let biometricAuthenticationEnabled: Bool
    public let certificatePinningEnabled: Bool
    public let inputValidationEnabled: Bool
    
    public init(
        encryptionEnabled: Bool = true,
        biometricAuthenticationEnabled: Bool = false,
        certificatePinningEnabled: Bool = true,
        inputValidationEnabled: Bool = true
    ) {
        self.encryptionEnabled = encryptionEnabled
        self.biometricAuthenticationEnabled = biometricAuthenticationEnabled
        self.certificatePinningEnabled = certificatePinningEnabled
        self.inputValidationEnabled = inputValidationEnabled
    }
} 
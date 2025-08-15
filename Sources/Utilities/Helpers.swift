//
//  Helpers.swift
//  GlobalLingo
//
//  Comprehensive Helper Utilities and Functions
//  Copyright © 2025 GlobalLingo. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import CoreLocation
import LocalAuthentication
import AVFoundation
import Network
import CryptoKit
import OSLog

// MARK: - Global Constants

public struct GlobalLingoConstants {
    
    // MARK: - App Information
    public static let appName = "GlobalLingo"
    public static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    public static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    public static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.globallingo.app"
    
    // MARK: - API Configuration
    public static let baseURL = "https://api.globallingo.com"
    public static let apiVersion = "v1"
    public static let timeout: TimeInterval = 30.0
    public static let maxRetries = 3
    
    // MARK: - Supported Languages
    public static let supportedLanguages = [
        "en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko",
        "ar", "hi", "th", "vi", "tr", "pl", "nl", "sv", "da", "no"
    ]
    
    // MARK: - Cache Configuration
    public static let maxCacheSize = 100_000_000 // 100MB
    public static let cacheExpiration: TimeInterval = 86400 // 24 hours
    public static let maxTranslationHistorySize = 1000
    
    // MARK: - Voice Recognition
    public static let maxRecordingDuration: TimeInterval = 60.0
    public static let minRecordingDuration: TimeInterval = 0.5
    public static let silenceThreshold: Float = -40.0
    
    // MARK: - Quality Thresholds
    public static let minQualityScore: Float = 0.7
    public static let maxTranslationLength = 5000
    public static let minTranslationLength = 1
    
    // MARK: - Animation Durations
    public static let defaultAnimationDuration: TimeInterval = 0.3
    public static let shortAnimationDuration: TimeInterval = 0.15
    public static let longAnimationDuration: TimeInterval = 0.6
    
    // MARK: - UI Constants
    public static let cornerRadius: CGFloat = 12.0
    public static let shadowRadius: CGFloat = 8.0
    public static let shadowOpacity: Float = 0.1
    public static let borderWidth: CGFloat = 1.0
    
    // MARK: - Spacing
    public static let smallSpacing: CGFloat = 8.0
    public static let mediumSpacing: CGFloat = 16.0
    public static let largeSpacing: CGFloat = 24.0
    public static let extraLargeSpacing: CGFloat = 32.0
    
    // MARK: - Font Sizes
    public static let captionFontSize: CGFloat = 12.0
    public static let bodyFontSize: CGFloat = 16.0
    public static let headlineFontSize: CGFloat = 20.0
    public static let titleFontSize: CGFloat = 24.0
    public static let largeTitleFontSize: CGFloat = 32.0
    
    // MARK: - Security
    public static let encryptionKeySize = 32
    public static let saltSize = 16
    public static let ivSize = 16
    public static let maxLoginAttempts = 5
    public static let lockoutDuration: TimeInterval = 300 // 5 minutes
}

// MARK: - Logging Helper

public final class LoggingHelper {
    
    private static let logger = Logger(subsystem: GlobalLingoConstants.bundleIdentifier, category: "LoggingHelper")
    
    public enum LogLevel: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
    }
    
    public static func log(
        _ message: String,
        level: LogLevel = .info,
        category: String = "General",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(category)] \(fileName):\(line) \(function) - \(message)"
        
        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        case .critical:
            logger.critical("\(logMessage)")
        }
        
        #if DEBUG
        print("[\(level.rawValue)] \(logMessage)")
        #endif
    }
    
    public static func logError(_ error: Error, context: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let errorMessage = "\(context.isEmpty ? "" : "\(context): ")\(error.localizedDescription)"
        log(errorMessage, level: .error, category: "Error", file: file, function: function, line: line)
    }
    
    public static func logPerformance<T>(
        operation: String,
        category: String = "Performance",
        closure: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try closure()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        log("Operation '\(operation)' completed in \(String(format: "%.4f", timeElapsed))s", 
            level: .debug, category: category)
        
        return result
    }
}

// MARK: - Validation Helper

public final class ValidationHelper {
    
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    public static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = #"^\+?[1-9]\d{1,14}$"#
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phoneNumber)
    }
    
    public static func isValidPassword(_ password: String) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        if password.count < 8 {
            errors.append("Password must be at least 8 characters long")
        }
        
        if !password.contains(where: { $0.isUppercase }) {
            errors.append("Password must contain at least one uppercase letter")
        }
        
        if !password.contains(where: { $0.isLowercase }) {
            errors.append("Password must contain at least one lowercase letter")
        }
        
        if !password.contains(where: { $0.isNumber }) {
            errors.append("Password must contain at least one number")
        }
        
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        if password.rangeOfCharacter(from: specialCharacters) == nil {
            errors.append("Password must contain at least one special character")
        }
        
        return (errors.isEmpty, errors)
    }
    
    public static func isValidName(_ name: String) -> Bool {
        let nameRegex = #"^[a-zA-Z\s]{2,50}$"#
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: name)
    }
    
    public static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    public static func isValidLanguageCode(_ code: String) -> Bool {
        return GlobalLingoConstants.supportedLanguages.contains(code)
    }
    
    public static func isValidTranslationText(_ text: String) -> (isValid: Bool, error: String?) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            return (false, "Text cannot be empty")
        }
        
        if trimmedText.count < GlobalLingoConstants.minTranslationLength {
            return (false, "Text is too short")
        }
        
        if trimmedText.count > GlobalLingoConstants.maxTranslationLength {
            return (false, "Text is too long (maximum \(GlobalLingoConstants.maxTranslationLength) characters)")
        }
        
        return (true, nil)
    }
    
    public static func sanitizeInput(_ input: String) -> String {
        // Remove potentially harmful characters and scripts
        let allowedCharacterSet = CharacterSet.alphanumerics
            .union(.whitespaces)
            .union(.punctuationCharacters)
            .union(.symbols)
        
        return input.unicodeScalars
            .filter { allowedCharacterSet.contains($0) }
            .map { String($0) }
            .joined()
    }
}

// MARK: - Network Helper

public final class NetworkHelper {
    
    public enum NetworkStatus {
        case unavailable
        case wifi
        case cellular
    }
    
    private static let networkMonitor = NWPathMonitor()
    private static var isMonitoring = false
    private static var currentStatus: NetworkStatus = .unavailable
    
    public static var isConnected: Bool {
        return currentStatus != .unavailable
    }
    
    public static var connectionType: NetworkStatus {
        return currentStatus
    }
    
    public static func startMonitoring() {
        guard !isMonitoring else { return }
        
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    if path.usesInterfaceType(.wifi) {
                        currentStatus = .wifi
                    } else if path.usesInterfaceType(.cellular) {
                        currentStatus = .cellular
                    } else {
                        currentStatus = .unavailable
                    }
                } else {
                    currentStatus = .unavailable
                }
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("NetworkStatusChanged"),
                    object: currentStatus
                )
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
        isMonitoring = true
    }
    
    public static func stopMonitoring() {
        networkMonitor.cancel()
        isMonitoring = false
    }
    
    public static func checkReachability(to host: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: host) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5.0
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }
        }.resume()
    }
    
    public static func downloadSpeed(completion: @escaping (Double) -> Void) {
        let testURL = URL(string: "https://httpbin.org/bytes/1024")!
        let startTime = CFAbsoluteTimeGetCurrent()
        
        URLSession.shared.dataTask(with: testURL) { data, _, _ in
            let endTime = CFAbsoluteTimeGetCurrent()
            let duration = endTime - startTime
            let speed = Double(data?.count ?? 0) / duration // bytes per second
            
            DispatchQueue.main.async {
                completion(speed)
            }
        }.resume()
    }
}

// MARK: - Device Helper

public final class DeviceHelper {
    
    public static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value))!)
        }
        return deviceName(for: identifier)
    }
    
    private static func deviceName(for identifier: String) -> String {
        switch identifier {
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "iPad13,18", "iPad13,19": return "iPad 10th Gen"
        case "iPad14,3", "iPad14,4": return "iPad Pro 11-inch 4th Gen"
        case "iPad14,5", "iPad14,6": return "iPad Pro 12.9-inch 6th Gen"
        default: return identifier
        }
    }
    
    public static var isJailbroken: Bool {
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // Try to write to system directory
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }
    
    public static var batteryLevel: Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
    }
    
    public static var batteryState: UIDevice.BatteryState {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryState
    }
    
    public static var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    public static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    public static var availableStorage: Int64 {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
            if let freeSize = dictionary[.systemFreeSize] as? NSNumber {
                return freeSize.int64Value
            }
        }
        return 0
    }
    
    public static var totalStorage: Int64 {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
            if let totalSize = dictionary[.systemSize] as? NSNumber {
                return totalSize.int64Value
            }
        }
        return 0
    }
    
    public static var isLowPowerModeEnabled: Bool {
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    public static var thermalState: ProcessInfo.ThermalState {
        return ProcessInfo.processInfo.thermalState
    }
    
    public static func hasFeature(_ feature: DeviceFeature) -> Bool {
        switch feature {
        case .touchID:
            return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        case .faceID:
            let context = LAContext()
            context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            return context.biometryType == .faceID
        case .camera:
            return UIImagePickerController.isSourceTypeAvailable(.camera)
        case .microphone:
            return AVAudioSession.sharedInstance().isInputAvailable
        case .gps:
            return CLLocationManager.locationServicesEnabled()
        case .nfc:
            return false // Requires specific NFC framework check
        }
    }
    
    public enum DeviceFeature {
        case touchID
        case faceID
        case camera
        case microphone
        case gps
        case nfc
    }
}

// MARK: - Keychain Helper

public final class KeychainHelper {
    
    public enum KeychainError: Error {
        case noValue
        case unexpectedValueData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    public static func save(_ value: String, for key: String, service: String = GlobalLingoConstants.bundleIdentifier) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public static func load(key: String, service: String = GlobalLingoConstants.bundleIdentifier) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let data = dataTypeRef as? Data else {
            throw KeychainError.unexpectedValueData
        }
        
        guard let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedValueData
        }
        
        return value
    }
    
    public static func delete(key: String, service: String = GlobalLingoConstants.bundleIdentifier) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public static func deleteAll(service: String = GlobalLingoConstants.bundleIdentifier) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public static func exists(key: String, service: String = GlobalLingoConstants.bundleIdentifier) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanFalse!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}

// MARK: - Biometric Helper

public final class BiometricHelper {
    
    public enum BiometricType {
        case none
        case touchID
        case faceID
        case unknown
    }
    
    public enum BiometricError: Error {
        case notAvailable
        case notEnrolled
        case cancelled
        case failed
        case lockout
        case systemCancel
        case passcodeNotSet
        case unknown(Error)
    }
    
    public static var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .unknown
        }
    }
    
    public static var isAvailable: Bool {
        return biometricType != .none
    }
    
    public static func authenticate(
        reason: String,
        completion: @escaping (Result<Bool, BiometricError>) -> Void
    ) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(.failure(.notAvailable))
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(true))
                } else if let error = error as? LAError {
                    switch error.code {
                    case .userCancel:
                        completion(.failure(.cancelled))
                    case .userFallback:
                        completion(.failure(.failed))
                    case .systemCancel:
                        completion(.failure(.systemCancel))
                    case .passcodeNotSet:
                        completion(.failure(.passcodeNotSet))
                    case .biometryNotAvailable:
                        completion(.failure(.notAvailable))
                    case .biometryNotEnrolled:
                        completion(.failure(.notEnrolled))
                    case .biometryLockout:
                        completion(.failure(.lockout))
                    default:
                        completion(.failure(.unknown(error)))
                    }
                } else {
                    completion(.failure(.failed))
                }
            }
        }
    }
}

// MARK: - Haptic Helper

public final class HapticHelper {
    
    public enum HapticType {
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        case selection
    }
    
    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let notification = UINotificationFeedbackGenerator()
    private static let selection = UISelectionFeedbackGenerator()
    
    public static func trigger(_ type: HapticType) {
        switch type {
        case .impact(let style):
            switch style {
            case .light:
                impactLight.prepare()
                impactLight.impactOccurred()
            case .medium:
                impactMedium.prepare()
                impactMedium.impactOccurred()
            case .heavy:
                impactHeavy.prepare()
                impactHeavy.impactOccurred()
            default:
                impactMedium.prepare()
                impactMedium.impactOccurred()
            }
        case .notification(let feedbackType):
            notification.prepare()
            notification.notificationOccurred(feedbackType)
        case .selection:
            selection.prepare()
            selection.selectionChanged()
        }
    }
    
    public static func prepare(_ type: HapticType) {
        switch type {
        case .impact(let style):
            switch style {
            case .light:
                impactLight.prepare()
            case .medium:
                impactMedium.prepare()
            case .heavy:
                impactHeavy.prepare()
            default:
                impactMedium.prepare()
            }
        case .notification:
            notification.prepare()
        case .selection:
            selection.prepare()
        }
    }
}

// MARK: - Crypto Helper

public final class CryptoHelper {
    
    public enum CryptoError: Error {
        case invalidData
        case encryptionFailed
        case decryptionFailed
        case keyGenerationFailed
    }
    
    public static func generateRandomKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
    
    public static func generateRandomData(size: Int) -> Data {
        var data = Data(count: size)
        _ = data.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, size, $0.baseAddress!) }
        return data
    }
    
    public static func encrypt(data: Data, key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined!
        } catch {
            throw CryptoError.encryptionFailed
        }
    }
    
    public static func decrypt(data: Data, key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            throw CryptoError.decryptionFailed
        }
    }
    
    public static func hash(data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    public static func hash(string: String) -> String {
        guard let data = string.data(using: .utf8) else { return "" }
        return hash(data: data)
    }
    
    public static func generateHMAC(data: Data, key: SymmetricKey) -> String {
        let hmac = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(hmac).base64EncodedString()
    }
    
    public static func verifyHMAC(data: Data, hmac: String, key: SymmetricKey) -> Bool {
        guard let hmacData = Data(base64Encoded: hmac) else { return false }
        return HMAC<SHA256>.isValidAuthenticationCode(hmacData, authenticating: data, using: key)
    }
}

// MARK: - Date Helper

public final class DateHelper {
    
    private static let dateFormatter = DateFormatter()
    private static let relativeDateFormatter = RelativeDateTimeFormatter()
    
    public enum DateFormat: String {
        case short = "MM/dd/yyyy"
        case medium = "MMM d, yyyy"
        case long = "MMMM d, yyyy"
        case full = "EEEE, MMMM d, yyyy"
        case time12 = "h:mm a"
        case time24 = "HH:mm"
        case dateTime = "MMM d, yyyy 'at' h:mm a"
        case iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case api = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    }
    
    public static func format(_ date: Date, as format: DateFormat) -> String {
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: date)
    }
    
    public static func relativeString(from date: Date, to referenceDate: Date = Date()) -> String {
        return relativeDateFormatter.localizedString(for: date, relativeTo: referenceDate)
    }
    
    public static func parse(_ dateString: String, format: DateFormat) -> Date? {
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: dateString)
    }
    
    public static func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    public static func isYesterday(_ date: Date) -> Bool {
        return Calendar.current.isDateInYesterday(date)
    }
    
    public static func isTomorrow(_ date: Date) -> Bool {
        return Calendar.current.isDateInTomorrow(date)
    }
    
    public static func daysBetween(_ date1: Date, and date2: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
    
    public static func age(from birthDate: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
    
    public static func startOfDay(_ date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    public static func endOfDay(_ date: Date = Date()) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
    }
    
    public static func startOfWeek(_ date: Date = Date()) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    public static func endOfWeek(_ date: Date = Date()) -> Date {
        let startOfWeek = self.startOfWeek(date)
        return Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
    }
}

// MARK: - Color Helper

public final class ColorHelper {
    
    public static func color(from hex: String) -> UIColor? {
        return UIColor(hex: hex)
    }
    
    public static func randomColor() -> UIColor {
        return UIColor.random
    }
    
    public static func blend(_ color1: UIColor, with color2: UIColor, ratio: CGFloat = 0.5) -> UIColor {
        return color1.blended(with: color2, ratio: ratio)
    }
    
    public static func isDark(_ color: UIColor) -> Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let brightness = (red * 0.299) + (green * 0.587) + (blue * 0.114)
        return brightness < 0.5
    }
    
    public static func contrastingTextColor(for backgroundColor: UIColor) -> UIColor {
        return isDark(backgroundColor) ? .white : .black
    }
    
    public static func generateColorPalette(from baseColor: UIColor, count: Int = 5) -> [UIColor] {
        var colors: [UIColor] = []
        
        for i in 0..<count {
            let ratio = CGFloat(i) / CGFloat(count - 1)
            let lightness = 0.3 + (ratio * 0.4) // Range from 30% to 70% lightness
            
            if ratio < 0.5 {
                colors.append(baseColor.darker(by: (0.5 - ratio) * 0.5))
            } else {
                colors.append(baseColor.lighter(by: (ratio - 0.5) * 0.5))
            }
        }
        
        return colors
    }
}

// MARK: - Animation Helper

public final class AnimationHelper {
    
    public enum AnimationType {
        case fadeIn
        case fadeOut
        case slideUp
        case slideDown
        case slideLeft
        case slideRight
        case scale
        case bounce
        case shake
        case flash
    }
    
    public static func animate(
        _ view: UIView,
        type: AnimationType,
        duration: TimeInterval = GlobalLingoConstants.defaultAnimationDuration,
        delay: TimeInterval = 0,
        completion: ((Bool) -> Void)? = nil
    ) {
        switch type {
        case .fadeIn:
            view.alpha = 0
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
                view.alpha = 1
            } completion: { finished in
                completion?(finished)
            }
            
        case .fadeOut:
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
                view.alpha = 0
            } completion: { finished in
                completion?(finished)
            }
            
        case .slideUp:
            let originalTransform = view.transform
            view.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
                view.transform = originalTransform
            } completion: { finished in
                completion?(finished)
            }
            
        case .slideDown:
            let originalTransform = view.transform
            view.transform = CGAffineTransform(translationX: 0, y: -view.frame.height)
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
                view.transform = originalTransform
            } completion: { finished in
                completion?(finished)
            }
            
        case .slideLeft:
            let originalTransform = view.transform
            view.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
                view.transform = originalTransform
            } completion: { finished in
                completion?(finished)
            }
            
        case .slideRight:
            let originalTransform = view.transform
            view.transform = CGAffineTransform(translationX: -view.frame.width, y: 0)
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
                view.transform = originalTransform
            } completion: { finished in
                completion?(finished)
            }
            
        case .scale:
            view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
                view.transform = CGAffineTransform.identity
            } completion: { finished in
                completion?(finished)
            }
            
        case .bounce:
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut) {
                view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                UIView.animate(withDuration: duration * 0.5) {
                    view.transform = CGAffineTransform.identity
                } completion: { finished in
                    completion?(finished)
                }
            }
            
        case .shake:
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = duration
            animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
            view.layer.add(animation, forKey: "shake")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                completion?(true)
            }
            
        case .flash:
            let originalBackgroundColor = view.backgroundColor
            UIView.animate(withDuration: duration * 0.5, delay: delay) {
                view.backgroundColor = UIColor.white
            } completion: { _ in
                UIView.animate(withDuration: duration * 0.5) {
                    view.backgroundColor = originalBackgroundColor
                } completion: { finished in
                    completion?(finished)
                }
            }
        }
    }
    
    public static func spring(
        _ view: UIView,
        scale: CGFloat = 1.05,
        duration: TimeInterval = 0.2,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            UIView.animate(withDuration: duration) {
                view.transform = CGAffineTransform.identity
            } completion: { finished in
                completion?(finished)
            }
        }
    }
}

// MARK: - Format Helper

public final class FormatHelper {
    
    private static let numberFormatter = NumberFormatter()
    private static let byteFormatter = ByteCountFormatter()
    
    public static func currency(_ amount: Double, currencyCode: String = "USD") -> String {
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode
        return numberFormatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    public static func percentage(_ value: Double, fractionDigits: Int = 2) -> String {
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = fractionDigits
        return numberFormatter.string(from: NSNumber(value: value)) ?? "0%"
    }
    
    public static func decimal(_ value: Double, fractionDigits: Int = 2) -> String {
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = fractionDigits
        return numberFormatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    public static func fileSize(_ bytes: Int64) -> String {
        byteFormatter.countStyle = .file
        return byteFormatter.string(fromByteCount: bytes)
    }
    
    public static func duration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    public static func ordinal(_ number: Int) -> String {
        numberFormatter.numberStyle = .ordinal
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    public static func spellOut(_ number: Int) -> String {
        numberFormatter.numberStyle = .spellOut
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    public static func phoneNumber(_ number: String) -> String {
        let digits = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if digits.count == 10 {
            let areaCode = String(digits.prefix(3))
            let centralOffice = String(digits.dropFirst(3).prefix(3))
            let subscriber = String(digits.suffix(4))
            return "(\(areaCode)) \(centralOffice)-\(subscriber)"
        } else if digits.count == 11 && digits.hasPrefix("1") {
            let areaCode = String(digits.dropFirst().prefix(3))
            let centralOffice = String(digits.dropFirst(4).prefix(3))
            let subscriber = String(digits.suffix(4))
            return "+1 (\(areaCode)) \(centralOffice)-\(subscriber)"
        }
        
        return number
    }
    
    public static func creditCard(_ number: String) -> String {
        let digits = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        var formatted = ""
        
        for (index, character) in digits.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted += String(character)
        }
        
        return formatted
    }
}

// MARK: - Error Helper

public final class ErrorHelper {
    
    public static func handle(_ error: Error, context: String = "", showAlert: Bool = false, in viewController: UIViewController? = nil) {
        LoggingHelper.logError(error, context: context)
        
        if showAlert, let vc = viewController {
            let alert = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            vc.present(alert, animated: true)
        }
    }
    
    public static func createAlert(for error: Error, title: String = "Error") -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return alert
    }
    
    public static func localizedDescription(for error: Error) -> String {
        if let localizedError = error as? LocalizedError {
            return localizedError.localizedDescription
        }
        
        return error.localizedDescription
    }
}

// MARK: - Threading Helper

public final class ThreadingHelper {
    
    public static func executeOnMain(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
    
    public static func executeOnBackground(_ closure: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            closure()
        }
    }
    
    public static func executeAfterDelay(_ delay: TimeInterval, _ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    
    public static func debounce(
        delay: TimeInterval,
        queue: DispatchQueue = .main,
        action: @escaping () -> Void
    ) -> () -> Void {
        var workItem: DispatchWorkItem?
        
        return {
            workItem?.cancel()
            workItem = DispatchWorkItem(block: action)
            queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
        }
    }
    
    public static func throttle(
        interval: TimeInterval,
        queue: DispatchQueue = .main,
        action: @escaping () -> Void
    ) -> () -> Void {
        var lastExecution = Date.distantPast
        
        return {
            let now = Date()
            if now.timeIntervalSince(lastExecution) >= interval {
                lastExecution = now
                queue.async {
                    action()
                }
            }
        }
    }
}

// MARK: - Memory Helper

public final class MemoryHelper {
    
    public static func memoryUsage() -> (used: UInt64, total: UInt64) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return (0, 0)
        }
        
        return (info.resident_size, ProcessInfo.processInfo.physicalMemory)
    }
    
    public static func clearMemoryCache() {
        URLCache.shared.removeAllCachedResponses()
        ImageCache.shared.clearMemoryCache()
    }
    
    public static func printMemoryUsage() {
        let usage = memoryUsage()
        let usedMB = Double(usage.used) / 1024 / 1024
        let totalMB = Double(usage.total) / 1024 / 1024
        let percentage = (Double(usage.used) / Double(usage.total)) * 100
        
        LoggingHelper.log(
            "Memory Usage: \(String(format: "%.2f", usedMB))MB / \(String(format: "%.2f", totalMB))MB (\(String(format: "%.1f", percentage))%)",
            level: .info,
            category: "Memory"
        )
    }
}

// MARK: - Image Cache Helper

public final class ImageCache {
    
    public static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    public func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString, cost: image.pngData()?.count ?? 0)
        
        // Save to disk
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                  let data = image.pngData() else { return }
            
            let fileURL = self.cacheDirectory.appendingPathComponent("\(key.hash).png")
            try? data.write(to: fileURL)
        }
    }
    
    public func image(forKey key: String) -> UIImage? {
        // Check memory cache first
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent("\(key.hash).png")
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: key as NSString, cost: data.count)
            return image
        }
        
        return nil
    }
    
    public func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let fileURL = cacheDirectory.appendingPathComponent("\(key.hash).png")
        try? fileManager.removeItem(at: fileURL)
    }
    
    public func clearMemoryCache() {
        cache.removeAllObjects()
    }
    
    public func clearDiskCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    public func clearAllCache() {
        clearMemoryCache()
        clearDiskCache()
    }
}
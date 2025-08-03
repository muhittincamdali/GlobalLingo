import Foundation
import Alamofire
import Crypto

/// Network service for GlobalLingo translation framework
/// Handles API communication, request/response processing, and network optimization
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public class NetworkService {
    
    // MARK: - Properties
    
    private let session: Session
    private var timeout: TimeInterval = 30.0
    private var retryCount = 3
    private var retryDelay: TimeInterval = 1.0
    
    private let baseURL = "https://api.globalLingo.com/v1"
    private let apiKey: String?
    
    // MARK: - Initialization
    
    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        
        session = Session(configuration: configuration)
        apiKey = getAPIKey()
    }
    
    // MARK: - Configuration
    
    /// Configure network service
    /// - Parameter timeout: Request timeout in seconds
    public func configure(timeout: TimeInterval) {
        self.timeout = timeout
    }
    
    // MARK: - Translation API
    
    /// Translate text using network API
    /// - Parameters:
    ///   - text: Text to translate
    ///   - from: Source language
    ///   - to: Target language
    /// - Returns: Translated text
    public func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> String {
        
        let endpoint = "/translate"
        let parameters: [String: Any] = [
            "text": text,
            "source": sourceLanguage.code,
            "target": targetLanguage.code,
            "format": "text"
        ]
        
        let request = createRequest(
            endpoint: endpoint,
            method: .post,
            parameters: parameters
        )
        
        return try await performRequest(request) { data in
            guard let response = try? JSONDecoder().decode(TranslationResponse.self, from: data),
                  let translatedText = response.translatedText else {
                throw NetworkError.invalidResponse
            }
            return translatedText
        }
    }
    
    /// Detect language using network API
    /// - Parameter text: Text to detect language for
    /// - Returns: Detected language
    public func detectLanguage(text: String) async throws -> Language {
        
        let endpoint = "/detect"
        let parameters: [String: Any] = [
            "text": text
        ]
        
        let request = createRequest(
            endpoint: endpoint,
            method: .post,
            parameters: parameters
        )
        
        return try await performRequest(request) { data in
            guard let response = try? JSONDecoder().decode(LanguageDetectionResponse.self, from: data),
                  let languageCode = response.detectedLanguage else {
                throw NetworkError.invalidResponse
            }
            
            guard let language = Language.byCode(languageCode) else {
                throw NetworkError.unsupportedLanguage
            }
            
            return language
        }
    }
    
    /// Get supported languages from API
    /// - Returns: Array of supported languages
    public func getSupportedLanguages() async throws -> [Language] {
        
        let endpoint = "/languages"
        let request = createRequest(
            endpoint: endpoint,
            method: .get,
            parameters: nil
        )
        
        return try await performRequest(request) { data in
            guard let response = try? JSONDecoder().decode(LanguagesResponse.self, from: data) else {
                throw NetworkError.invalidResponse
            }
            
            return response.languages.compactMap { languageData in
                Language(
                    id: languageData.code,
                    code: languageData.code,
                    name: languageData.name,
                    nativeName: languageData.nativeName,
                    isSupported: languageData.isSupported,
                    isOfflineAvailable: languageData.isOfflineAvailable,
                    isVoiceSupported: languageData.isVoiceSupported
                )
            }
        }
    }
    
    /// Download language model
    /// - Parameter language: Language for the model
    /// - Returns: Model data
    public func downloadLanguageModel(language: Language) async throws -> Data {
        
        let endpoint = "/models/\(language.code)"
        let request = createRequest(
            endpoint: endpoint,
            method: .get,
            parameters: nil
        )
        
        return try await performRequest(request) { data in
            return data
        }
    }
    
    // MARK: - Voice Recognition API
    
    /// Recognize speech using network API
    /// - Parameters:
    ///   - audioData: Audio data to recognize
    ///   - language: Language for recognition
    /// - Returns: Recognized text
    public func recognizeSpeech(
        audioData: Data,
        language: Language
    ) async throws -> String {
        
        let endpoint = "/speech/recognize"
        let parameters: [String: Any] = [
            "language": language.code,
            "format": "audio/wav"
        ]
        
        let request = createRequest(
            endpoint: endpoint,
            method: .post,
            parameters: parameters,
            data: audioData
        )
        
        return try await performRequest(request) { data in
            guard let response = try? JSONDecoder().decode(SpeechRecognitionResponse.self, from: data),
                  let recognizedText = response.text else {
                throw NetworkError.invalidResponse
            }
            return recognizedText
        }
    }
    
    /// Synthesize speech using network API
    /// - Parameters:
    ///   - text: Text to synthesize
    ///   - language: Language for synthesis
    /// - Returns: Audio data
    public func synthesizeSpeech(
        text: String,
        language: Language
    ) async throws -> Data {
        
        let endpoint = "/speech/synthesize"
        let parameters: [String: Any] = [
            "text": text,
            "language": language.code,
            "format": "audio/wav"
        ]
        
        let request = createRequest(
            endpoint: endpoint,
            method: .post,
            parameters: parameters
        )
        
        return try await performRequest(request) { data in
            return data
        }
    }
    
    // MARK: - Private Methods
    
    private func createRequest(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        data: Data? = nil
    ) -> URLRequest {
        
        var request = URLRequest(url: URL(string: baseURL + endpoint)!)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        
        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("GlobalLingo/1.0", forHTTPHeaderField: "User-Agent")
        
        if let apiKey = apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        // Add parameters
        if let parameters = parameters {
            if method == .get {
                // Add to URL for GET requests
                var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
                components.queryItems = parameters.map { key, value in
                    URLQueryItem(name: key, value: "\(value)")
                }
                request.url = components.url
            } else {
                // Add to body for other requests
                if let data = data {
                    request.httpBody = data
                } else {
                    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
                }
            }
        }
        
        return request
    }
    
    private func performRequest<T>(
        _ request: URLRequest,
        responseHandler: @escaping (Data) throws -> T
    ) async throws -> T {
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(request)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let result = try responseHandler(data)
                            continuation.resume(returning: result)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: NetworkError.requestFailed(error))
                    }
                }
        }
    }
    
    private func getAPIKey() -> String? {
        // In a real implementation, this would load from secure storage
        return nil
    }
}

// MARK: - Response Models

private struct TranslationResponse: Codable {
    let translatedText: String?
    let confidence: Float?
    let detectedLanguage: String?
}

private struct LanguageDetectionResponse: Codable {
    let detectedLanguage: String?
    let confidence: Float?
    let alternatives: [String]?
}

private struct LanguagesResponse: Codable {
    let languages: [LanguageData]
}

private struct LanguageData: Codable {
    let code: String
    let name: String
    let nativeName: String
    let isSupported: Bool
    let isOfflineAvailable: Bool
    let isVoiceSupported: Bool
}

private struct SpeechRecognitionResponse: Codable {
    let text: String?
    let confidence: Float?
    let language: String?
}

// MARK: - Network Error

public enum NetworkError: LocalizedError {
    case invalidResponse
    case requestFailed(Error)
    case unsupportedLanguage
    case authenticationFailed
    case rateLimitExceeded
    case serverError
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .unsupportedLanguage:
            return "Language is not supported"
        case .authenticationFailed:
            return "Authentication failed"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .serverError:
            return "Server error"
        case .networkUnavailable:
            return "Network is unavailable"
        }
    }
} 
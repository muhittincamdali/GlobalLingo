import Foundation
import CryptoKit

/// Network service for GlobalLingo translation framework
/// Handles API communication, request/response processing, and network optimization
@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
public class NetworkService: Sendable {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let timeout: TimeInterval = 30.0
    private let baseURL = "https://api.globalLingo.com/v1"
    private let apiKey: String?
    
    // MARK: - Initialization
    
    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        
        self.session = URLSession(configuration: configuration)
        self.apiKey = nil // Stubbed
    }
    
    // MARK: - Translation API
    
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
        
        let request = try createRequest(endpoint: endpoint, method: "POST", parameters: parameters)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(TranslationResponse.self, from: data)
        return result.translatedText ?? ""
    }
    
    public func detectLanguage(text: String) async throws -> Language {
        let endpoint = "/detect"
        let parameters: [String: Any] = ["text": text]
        let request = try createRequest(endpoint: endpoint, method: "POST", parameters: parameters)
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(LanguageDetectionResponse.self, from: data)
        
        guard let languageCode = response.detectedLanguage,
              let language = Language.byCode(languageCode) else {
            throw NetworkError.unsupportedLanguage
        }
        
        return language
    }
    
    // MARK: - Private Methods
    
    private func createRequest(
        endpoint: String,
        method: String,
        parameters: [String: Any]?,
        data: Data? = nil
    ) throws -> URLRequest {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("GlobalLingo/1.0", forHTTPHeaderField: "User-Agent")
        
        if method != "GET", let parameters = parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }
        
        return request
    }
}

// MARK: - Response Models

private struct TranslationResponse: Codable {
    let translatedText: String?
}

private struct LanguageDetectionResponse: Codable {
    let detectedLanguage: String?
}

// MARK: - Network Error

public enum NetworkError: LocalizedError {
    case invalidResponse
    case requestFailed(Error)
    case unsupportedLanguage
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response"
        case .requestFailed(let error): return error.localizedDescription
        case .unsupportedLanguage: return "Unsupported language"
        }
    }
}

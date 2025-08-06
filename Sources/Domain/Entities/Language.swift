import Foundation

/// Represents a language supported by the GlobalLingo framework
public struct Language: Codable, Identifiable, Hashable {
    
    // MARK: - Properties
    
    /// Unique identifier for the language
    public let id: String
    
    /// ISO 639-1 language code (e.g., "en", "es", "fr")
    public let code: String
    
    /// Language name in English
    public let name: String
    
    /// Language name in its native script
    public let nativeName: String
    
    /// Whether the language is supported by the framework
    public let isSupported: Bool
    
    /// Text direction for the language
    public let direction: TextDirection
    
    /// Regional variants of the language
    public let regionalVariants: [String]
    
    /// Pluralization rules for the language
    public let pluralizationRules: PluralizationRules
    
    // MARK: - Initialization
    
    /// Initialize a new Language instance
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - code: ISO 639-1 language code
    ///   - name: Language name in English
    ///   - nativeName: Language name in native script
    ///   - isSupported: Whether the language is supported
    ///   - direction: Text direction
    ///   - regionalVariants: Regional variants
    ///   - pluralizationRules: Pluralization rules
    public init(
        id: String,
        code: String,
        name: String,
        nativeName: String,
        isSupported: Bool = true,
        direction: TextDirection = .leftToRight,
        regionalVariants: [String] = [],
        pluralizationRules: PluralizationRules = PluralizationRules()
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.nativeName = nativeName
        self.isSupported = isSupported
        self.direction = direction
        self.regionalVariants = regionalVariants
        self.pluralizationRules = pluralizationRules
    }
    
    // MARK: - Computed Properties
    
    /// Whether the language is right-to-left
    public var isRTL: Bool {
        return direction == .rightToLeft
    }
    
    /// Display name for the language
    public var displayName: String {
        return "\(name) (\(nativeName))"
    }
    
    /// Whether the language has regional variants
    public var hasRegionalVariants: Bool {
        return !regionalVariants.isEmpty
    }
}

// MARK: - Text Direction

/// Represents text direction for languages
public enum TextDirection: String, Codable, CaseIterable {
    case leftToRight = "ltr"
    case rightToLeft = "rtl"
    case natural = "natural"
    case inherit = "inherit"
}

// MARK: - Pluralization Rules

/// Represents pluralization rules for a language
public struct PluralizationRules: Codable, Hashable {
    
    /// Zero form rule
    public let zero: String?
    
    /// One form rule
    public let one: String?
    
    /// Two form rule
    public let two: String?
    
    /// Few form rule
    public let few: String?
    
    /// Many form rule
    public let many: String?
    
    /// Other form rule (default)
    public let other: String
    
    /// Initialize pluralization rules
    /// - Parameters:
    ///   - zero: Zero form rule
    ///   - one: One form rule
    ///   - two: Two form rule
    ///   - few: Few form rule
    ///   - many: Many form rule
    ///   - other: Other form rule
    public init(
        zero: String? = nil,
        one: String? = nil,
        two: String? = nil,
        few: String? = nil,
        many: String? = nil,
        other: String = "other"
    ) {
        self.zero = zero
        self.one = one
        self.two = two
        self.few = few
        self.many = many
        self.other = other
    }
}

// MARK: - Language Extensions

extension Language {
    
    /// Common languages supported by GlobalLingo
    public static let commonLanguages: [Language] = [
        Language(id: "en", code: "en", name: "English", nativeName: "English"),
        Language(id: "es", code: "es", name: "Spanish", nativeName: "Español"),
        Language(id: "fr", code: "fr", name: "French", nativeName: "Français"),
        Language(id: "de", code: "de", name: "German", nativeName: "Deutsch"),
        Language(id: "it", code: "it", name: "Italian", nativeName: "Italiano"),
        Language(id: "pt", code: "pt", name: "Portuguese", nativeName: "Português"),
        Language(id: "ru", code: "ru", name: "Russian", nativeName: "Русский"),
        Language(id: "zh", code: "zh", name: "Chinese", nativeName: "中文"),
        Language(id: "ja", code: "ja", name: "Japanese", nativeName: "日本語"),
        Language(id: "ko", code: "ko", name: "Korean", nativeName: "한국어"),
        Language(id: "ar", code: "ar", name: "Arabic", nativeName: "العربية", direction: .rightToLeft),
        Language(id: "he", code: "he", name: "Hebrew", nativeName: "עברית", direction: .rightToLeft),
        Language(id: "hi", code: "hi", name: "Hindi", nativeName: "हिन्दी"),
        Language(id: "tr", code: "tr", name: "Turkish", nativeName: "Türkçe"),
        Language(id: "nl", code: "nl", name: "Dutch", nativeName: "Nederlands"),
        Language(id: "sv", code: "sv", name: "Swedish", nativeName: "Svenska"),
        Language(id: "da", code: "da", name: "Danish", nativeName: "Dansk"),
        Language(id: "no", code: "no", name: "Norwegian", nativeName: "Norsk"),
        Language(id: "fi", code: "fi", name: "Finnish", nativeName: "Suomi"),
        Language(id: "pl", code: "pl", name: "Polish", nativeName: "Polski")
    ]
    
    /// Find language by code
    /// - Parameter code: ISO 639-1 language code
    /// - Returns: Language if found, nil otherwise
    public static func findByCode(_ code: String) -> Language? {
        return commonLanguages.first { $0.code == code }
    }
    
    /// Check if language code is supported
    /// - Parameter code: ISO 639-1 language code
    /// - Returns: True if supported, false otherwise
    public static func isSupported(_ code: String) -> Bool {
        return findByCode(code)?.isSupported ?? false
    }
}

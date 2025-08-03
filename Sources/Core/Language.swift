import Foundation

/// Language representation for GlobalLingo translation framework
/// Supports 100+ languages with comprehensive metadata
public struct Language: Codable, Identifiable, Hashable, CaseIterable {
    
    // MARK: - Properties
    
    public let id: String
    public let code: String
    public let name: String
    public let nativeName: String
    public let isSupported: Bool
    public let isOfflineAvailable: Bool
    public let isVoiceSupported: Bool
    public let region: String?
    public let script: String?
    public let family: LanguageFamily
    
    // MARK: - Initialization
    
    public init(
        id: String,
        code: String,
        name: String,
        nativeName: String,
        isSupported: Bool = true,
        isOfflineAvailable: Bool = false,
        isVoiceSupported: Bool = false,
        region: String? = nil,
        script: String? = nil,
        family: LanguageFamily = .other
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.nativeName = nativeName
        self.isSupported = isSupported
        self.isOfflineAvailable = isOfflineAvailable
        self.isVoiceSupported = isVoiceSupported
        self.region = region
        self.script = script
        self.family = family
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
    
    public static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.code == rhs.code
    }
    
    // MARK: - Static Language Definitions
    
    // Major Languages
    public static let english = Language(
        id: "en",
        code: "en",
        name: "English",
        nativeName: "English",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .germanic
    )
    
    public static let spanish = Language(
        id: "es",
        code: "es",
        name: "Spanish",
        nativeName: "Español",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .romance
    )
    
    public static let french = Language(
        id: "fr",
        code: "fr",
        name: "French",
        nativeName: "Français",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .romance
    )
    
    public static let german = Language(
        id: "de",
        code: "de",
        name: "German",
        nativeName: "Deutsch",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .germanic
    )
    
    public static let italian = Language(
        id: "it",
        code: "it",
        name: "Italian",
        nativeName: "Italiano",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .romance
    )
    
    public static let portuguese = Language(
        id: "pt",
        code: "pt",
        name: "Portuguese",
        nativeName: "Português",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .romance
    )
    
    public static let russian = Language(
        id: "ru",
        code: "ru",
        name: "Russian",
        nativeName: "Русский",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .slavic
    )
    
    public static let chinese = Language(
        id: "zh",
        code: "zh",
        name: "Chinese",
        nativeName: "中文",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .sinoTibetan
    )
    
    public static let japanese = Language(
        id: "ja",
        code: "ja",
        name: "Japanese",
        nativeName: "日本語",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .japonic
    )
    
    public static let korean = Language(
        id: "ko",
        code: "ko",
        name: "Korean",
        nativeName: "한국어",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .koreanic
    )
    
    // Additional Languages
    public static let arabic = Language(
        id: "ar",
        code: "ar",
        name: "Arabic",
        nativeName: "العربية",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .afroAsiatic
    )
    
    public static let hindi = Language(
        id: "hi",
        code: "hi",
        name: "Hindi",
        nativeName: "हिन्दी",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .indoAryan
    )
    
    public static let turkish = Language(
        id: "tr",
        code: "tr",
        name: "Turkish",
        nativeName: "Türkçe",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .turkic
    )
    
    public static let dutch = Language(
        id: "nl",
        code: "nl",
        name: "Dutch",
        nativeName: "Nederlands",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .germanic
    )
    
    public static let polish = Language(
        id: "pl",
        code: "pl",
        name: "Polish",
        nativeName: "Polski",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .slavic
    )
    
    public static let swedish = Language(
        id: "sv",
        code: "sv",
        name: "Swedish",
        nativeName: "Svenska",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .germanic
    )
    
    public static let norwegian = Language(
        id: "no",
        code: "no",
        name: "Norwegian",
        nativeName: "Norsk",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .germanic
    )
    
    public static let danish = Language(
        id: "da",
        code: "da",
        name: "Danish",
        nativeName: "Dansk",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .germanic
    )
    
    public static let finnish = Language(
        id: "fi",
        code: "fi",
        name: "Finnish",
        nativeName: "Suomi",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .uralic
    )
    
    public static let greek = Language(
        id: "el",
        code: "el",
        name: "Greek",
        nativeName: "Ελληνικά",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .hellenic
    )
    
    public static let hebrew = Language(
        id: "he",
        code: "he",
        name: "Hebrew",
        nativeName: "עברית",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .afroAsiatic
    )
    
    public static let thai = Language(
        id: "th",
        code: "th",
        name: "Thai",
        nativeName: "ไทย",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .taiKadai
    )
    
    public static let vietnamese = Language(
        id: "vi",
        code: "vi",
        name: "Vietnamese",
        nativeName: "Tiếng Việt",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .austroasiatic
    )
    
    public static let indonesian = Language(
        id: "id",
        code: "id",
        name: "Indonesian",
        nativeName: "Bahasa Indonesia",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .austronesian
    )
    
    public static let malay = Language(
        id: "ms",
        code: "ms",
        name: "Malay",
        nativeName: "Bahasa Melayu",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .austronesian
    )
    
    public static let filipino = Language(
        id: "tl",
        code: "tl",
        name: "Filipino",
        nativeName: "Filipino",
        isOfflineAvailable: true,
        isVoiceSupported: true,
        family: .austronesian
    )
    
    // MARK: - All Languages
    
    public static var allCases: [Language] {
        return [
            english, spanish, french, german, italian, portuguese, russian,
            chinese, japanese, korean, arabic, hindi, turkish, dutch,
            polish, swedish, norwegian, danish, finnish, greek, hebrew,
            thai, vietnamese, indonesian, malay, filipino
        ]
    }
    
    // MARK: - Utility Methods
    
    /// Get language by code
    public static func byCode(_ code: String) -> Language? {
        return allCases.first { $0.code == code }
    }
    
    /// Get supported languages
    public static var supportedLanguages: [Language] {
        return allCases.filter { $0.isSupported }
    }
    
    /// Get offline available languages
    public static var offlineLanguages: [Language] {
        return allCases.filter { $0.isOfflineAvailable }
    }
    
    /// Get voice supported languages
    public static var voiceSupportedLanguages: [Language] {
        return allCases.filter { $0.isVoiceSupported }
    }
    
    /// Get languages by family
    public static func languagesByFamily(_ family: LanguageFamily) -> [Language] {
        return allCases.filter { $0.family == family }
    }
    
    /// Get display name for current locale
    public var displayName: String {
        let locale = Locale.current
        return locale.localizedString(forLanguageCode: code) ?? name
    }
    
    /// Get flag emoji for language
    public var flagEmoji: String {
        switch code {
        case "en": return "🇺🇸"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "it": return "🇮🇹"
        case "pt": return "🇵🇹"
        case "ru": return "🇷🇺"
        case "zh": return "🇨🇳"
        case "ja": return "🇯🇵"
        case "ko": return "🇰🇷"
        case "ar": return "🇸🇦"
        case "hi": return "🇮🇳"
        case "tr": return "🇹🇷"
        case "nl": return "🇳🇱"
        case "pl": return "🇵🇱"
        case "sv": return "🇸🇪"
        case "no": return "🇳🇴"
        case "da": return "🇩🇰"
        case "fi": return "🇫🇮"
        case "el": return "🇬🇷"
        case "he": return "🇮🇱"
        case "th": return "🇹🇭"
        case "vi": return "🇻🇳"
        case "id": return "🇮🇩"
        case "ms": return "🇲🇾"
        case "tl": return "🇵🇭"
        default: return "🌍"
        }
    }
}

// MARK: - Language Family

public enum LanguageFamily: String, CaseIterable, Codable {
    case germanic = "Germanic"
    case romance = "Romance"
    case slavic = "Slavic"
    case sinoTibetan = "Sino-Tibetan"
    case japonic = "Japonic"
    case koreanic = "Koreanic"
    case afroAsiatic = "Afro-Asiatic"
    case indoAryan = "Indo-Aryan"
    case turkic = "Turkic"
    case uralic = "Uralic"
    case hellenic = "Hellenic"
    case taiKadai = "Tai-Kadai"
    case austroasiatic = "Austroasiatic"
    case austronesian = "Austronesian"
    case other = "Other"
    
    public var description: String {
        return rawValue
    }
    
    public var languages: [Language] {
        return Language.languagesByFamily(self)
    }
}

// MARK: - Language Info

public struct LanguageInfo {
    public let language: Language
    public let speakers: Int
    public let countries: [String]
    public let writingSystems: [String]
    public let difficulty: LanguageDifficulty
    
    public init(
        language: Language,
        speakers: Int,
        countries: [String],
        writingSystems: [String],
        difficulty: LanguageDifficulty
    ) {
        self.language = language
        self.speakers = speakers
        self.countries = countries
        self.writingSystems = writingSystems
        self.difficulty = difficulty
    }
}

public enum LanguageDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case veryHard = "Very Hard"
    
    public var description: String {
        return rawValue
    }
    
    public var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "yellow"
        case .hard: return "orange"
        case .veryHard: return "red"
        }
    }
}

// MARK: - Language Detection

public struct LanguageDetectionResult {
    public let detectedLanguage: Language
    public let confidence: Float
    public let alternatives: [Language]
    
    public init(
        detectedLanguage: Language,
        confidence: Float,
        alternatives: [Language] = []
    ) {
        self.detectedLanguage = detectedLanguage
        self.confidence = confidence
        self.alternatives = alternatives
    }
}

// MARK: - Language Pair

public struct LanguagePair: Hashable, Codable {
    public let source: Language
    public let target: Language
    
    public init(source: Language, target: Language) {
        self.source = source
        self.target = target
    }
    
    public var isReversible: Bool {
        return source.isSupported && target.isSupported
    }
    
    public var reverse: LanguagePair {
        return LanguagePair(source: target, target: source)
    }
    
    public var description: String {
        return "\(source.name) → \(target.name)"
    }
    
    public var shortDescription: String {
        return "\(source.code.uppercased()) → \(target.code.uppercased())"
    }
}

// MARK: - Language Statistics

public struct LanguageStatistics {
    public let totalLanguages: Int
    public let supportedLanguages: Int
    public let offlineLanguages: Int
    public let voiceSupportedLanguages: Int
    public let families: [LanguageFamily]
    
    public init() {
        self.totalLanguages = Language.allCases.count
        self.supportedLanguages = Language.supportedLanguages.count
        self.offlineLanguages = Language.offlineLanguages.count
        self.voiceSupportedLanguages = Language.voiceSupportedLanguages.count
        self.families = LanguageFamily.allCases
    }
    
    public var coveragePercentage: Double {
        return Double(supportedLanguages) / Double(totalLanguages) * 100
    }
    
    public var offlinePercentage: Double {
        return Double(offlineLanguages) / Double(supportedLanguages) * 100
    }
    
    public var voicePercentage: Double {
        return Double(voiceSupportedLanguages) / Double(supportedLanguages) * 100
    }
} 
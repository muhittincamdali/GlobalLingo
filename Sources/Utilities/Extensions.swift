//
//  Extensions.swift
//  GlobalLingo
//
//  Comprehensive Swift Extensions for Enhanced Functionality
//  Copyright © 2025 GlobalLingo. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import CoreLocation
import CryptoKit
import OSLog

// MARK: - String Extensions

extension String {
    
    /// Validates if string is a valid email address
    var isValidEmail: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    /// Validates if string is a valid phone number
    var isValidPhoneNumber: Bool {
        let phoneRegex = #"^\+?[1-9]\d{1,14}$"#
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self)
    }
    
    /// Validates if string contains only letters and spaces
    var isValidName: Bool {
        let nameRegex = #"^[a-zA-Z\s]+$"#
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self)
    }
    
    /// Returns the character count excluding whitespaces
    var nonWhitespaceCount: Int {
        return components(separatedBy: .whitespacesAndNewlines).joined().count
    }
    
    /// Returns word count
    var wordCount: Int {
        return components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    /// Returns sentence count
    var sentenceCount: Int {
        return components(separatedBy: CharacterSet(charactersIn: ".!?")).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
    
    /// Calculates reading time in minutes (assuming 200 words per minute)
    var readingTime: Int {
        return max(1, wordCount / 200)
    }
    
    /// Removes HTML tags from string
    var htmlStripped: String {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    /// Converts string to Base64
    var base64Encoded: String {
        return Data(utf8).base64EncodedString()
    }
    
    /// Decodes Base64 string
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Generates SHA256 hash
    var sha256: String {
        let inputData = Data(utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Capitalizes first letter of each word
    var titleCased: String {
        return localizedCapitalized
    }
    
    /// Returns camelCase version of string
    var camelCased: String {
        let components = self.components(separatedBy: CharacterSet.alphanumerics.inverted)
        return ([components.first?.lowercased()] + components.dropFirst().map { $0.capitalized }).compactMap { $0 }.joined()
    }
    
    /// Returns snake_case version of string
    var snakeCased: String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
    }
    
    /// Returns kebab-case version of string
    var kebabCased: String {
        return snakeCased.replacingOccurrences(of: "_", with: "-")
    }
    
    /// Truncates string to specified length with ellipsis
    func truncated(to length: Int, trailing: String = "...") -> String {
        return count > length ? String(prefix(length)) + trailing : self
    }
    
    /// Pads string to specified length
    func padded(toLength length: Int, withPad pad: String = " ", startingAt index: Int = 0) -> String {
        return padding(toLength: length, withPad: pad, startingAt: index)
    }
    
    /// Removes specified prefix if present
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
    
    /// Removes specified suffix if present
    func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
    
    /// Converts string to slug format
    var slugified: String {
        return lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }
    
    /// Counts occurrences of substring
    func count(of substring: String) -> Int {
        return components(separatedBy: substring).count - 1
    }
    
    /// Checks if string contains only numeric characters
    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    /// Checks if string contains only alphabetic characters
    var isAlphabetic: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.letters.inverted) == nil
    }
    
    /// Checks if string is alphanumeric
    var isAlphanumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
    
    /// Returns the string as an optional URL
    var url: URL? {
        return URL(string: self)
    }
    
    /// Returns localized string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
    
    /// Safely subscripts string with range
    func safeSubstring(from start: Int, to end: Int) -> String {
        let startIndex = index(startIndex, offsetBy: max(0, start))
        let endIndex = index(startIndex, offsetBy: min(count - start, end - start))
        return String(self[startIndex..<endIndex])
    }
    
    /// Returns string with first character uppercased
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst()
    }
    
    /// Returns string with first character lowercased
    var lowercasedFirst: String {
        guard !isEmpty else { return self }
        return prefix(1).lowercased() + dropFirst()
    }
    
    /// Reverses the string
    var reversed: String {
        return String(self.reversed())
    }
    
    /// Checks if string is palindrome
    var isPalindrome: Bool {
        let cleaned = lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        return cleaned == String(cleaned.reversed())
    }
    
    /// Returns unique characters in string
    var uniqueCharacters: String {
        return String(Set(self).sorted())
    }
    
    /// Returns most frequent character
    var mostFrequentCharacter: Character? {
        let characterCounts = Dictionary(self.map { ($0, 1) }, uniquingKeysWith: +)
        return characterCounts.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Array Extensions

extension Array {
    
    /// Safely accesses element at index
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    /// Removes duplicate elements (requires Hashable)
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
    
    /// Chunks array into smaller arrays of specified size
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    /// Groups elements by key
    func grouped<Key: Hashable>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] {
        return Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }
    
    /// Returns random element if array is not empty
    var randomElement: Element? {
        return isEmpty ? nil : self[Int.random(in: 0..<count)]
    }
    
    /// Shuffles array in place
    mutating func shuffle() {
        for i in 0..<count {
            let randomIndex = Int.random(in: i..<count)
            swapAt(i, randomIndex)
        }
    }
    
    /// Returns shuffled copy of array
    func shuffled() -> [Element] {
        var copy = self
        copy.shuffle()
        return copy
    }
}

extension Array where Element: Equatable {
    
    /// Removes all occurrences of element
    mutating func removeAll(_ element: Element) {
        self = filter { $0 != element }
    }
    
    /// Removes duplicate elements
    func removingDuplicates() -> [Element] {
        var result: [Element] = []
        for element in self {
            if !result.contains(element) {
                result.append(element)
            }
        }
        return result
    }
    
    /// Returns unique elements preserving order
    var unique: [Element] {
        return removingDuplicates()
    }
}

extension Array where Element: Numeric {
    
    /// Returns sum of all elements
    var sum: Element {
        return reduce(0, +)
    }
    
    /// Returns average of all elements
    var average: Element {
        return isEmpty ? 0 : sum / Element(count)
    }
}

extension Array where Element: Comparable {
    
    /// Returns minimum and maximum elements as tuple
    var minMax: (min: Element, max: Element)? {
        guard let first = first else { return nil }
        return reduce((first, first)) { (minMax, element) in
            (min(minMax.min, element), max(minMax.max, element))
        }
    }
    
    /// Checks if array is sorted in ascending order
    var isSorted: Bool {
        return zip(self, dropFirst()).allSatisfy(<=)
    }
    
    /// Binary search for element (array must be sorted)
    func binarySearch(for element: Element) -> Int? {
        var left = 0
        var right = count - 1
        
        while left <= right {
            let mid = (left + right) / 2
            let midElement = self[mid]
            
            if midElement == element {
                return mid
            } else if midElement < element {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        return nil
    }
}

// MARK: - Dictionary Extensions

extension Dictionary {
    
    /// Safely gets value for key
    subscript(safe key: Key) -> Value? {
        return self[key]
    }
    
    /// Merges two dictionaries
    func merged(with other: [Key: Value]) -> [Key: Value] {
        return merging(other) { _, new in new }
    }
    
    /// Maps dictionary values
    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [Key: T] {
        return try self.mapValues(transform)
    }
    
    /// Filters dictionary by predicate
    func filtered(_ predicate: (Key, Value) throws -> Bool) rethrows -> [Key: Value] {
        return try filter(predicate).reduce(into: [:]) { result, pair in
            result[pair.key] = pair.value
        }
    }
    
    /// Compacts dictionary by removing nil values
    func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> [Key: T] {
        return try compactMapValues(transform)
    }
}

// MARK: - Date Extensions

extension Date {
    
    /// Returns date formatted as string
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    /// Returns date formatted with custom format
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Returns relative time string (e.g., "2 hours ago")
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Checks if date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Checks if date is yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Checks if date is tomorrow
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    /// Checks if date is in current week
    var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Checks if date is in current month
    var isThisMonth: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// Checks if date is in current year
    var isThisYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    /// Returns start of day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Returns end of day
    var endOfDay: Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        return calendar.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
    }
    
    /// Returns start of week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns end of week
    var endOfWeek: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!.addingTimeInterval(-1)
    }
    
    /// Returns start of month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns end of month
    var endOfMonth: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: 1, to: startOfMonth)!.addingTimeInterval(-1)
    }
    
    /// Returns start of year
    var startOfYear: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns end of year
    var endOfYear: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .year, value: 1, to: startOfYear)!.addingTimeInterval(-1)
    }
    
    /// Returns age from date
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
    }
    
    /// Returns zodiac sign
    var zodiacSign: String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        
        switch (month, day) {
        case (3, 21...31), (4, 1...19): return "Aries"
        case (4, 20...30), (5, 1...20): return "Taurus"
        case (5, 21...31), (6, 1...20): return "Gemini"
        case (6, 21...30), (7, 1...22): return "Cancer"
        case (7, 23...31), (8, 1...22): return "Leo"
        case (8, 23...31), (9, 1...22): return "Virgo"
        case (9, 23...30), (10, 1...22): return "Libra"
        case (10, 23...31), (11, 1...21): return "Scorpio"
        case (11, 22...30), (12, 1...21): return "Sagittarius"
        case (12, 22...31), (1, 1...19): return "Capricorn"
        case (1, 20...31), (2, 1...18): return "Aquarius"
        case (2, 19...29), (3, 1...20): return "Pisces"
        default: return "Unknown"
        }
    }
    
    /// Adds time interval
    func adding(_ component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }
    
    /// Subtracts time interval
    func subtracting(_ component: Calendar.Component, value: Int) -> Date {
        return adding(component, value: -value)
    }
    
    /// Returns difference between dates
    func difference(_ component: Calendar.Component, to date: Date) -> Int {
        return Calendar.current.dateComponents([component], from: self, to: date).value(for: component) ?? 0
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {
    
    /// Returns formatted duration string
    var durationString: String {
        let hours = Int(self) / 3600
        let minutes = Int(self % 3600) / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// Returns human readable duration
    var humanReadableDuration: String {
        let hours = Int(self) / 3600
        let minutes = Int(self % 3600) / 60
        let seconds = Int(self) % 60
        
        var components: [String] = []
        
        if hours > 0 {
            components.append("\(hours) hour\(hours == 1 ? "" : "s")")
        }
        
        if minutes > 0 {
            components.append("\(minutes) minute\(minutes == 1 ? "" : "s")")
        }
        
        if seconds > 0 || components.isEmpty {
            components.append("\(seconds) second\(seconds == 1 ? "" : "s")")
        }
        
        return components.joined(separator: ", ")
    }
    
    /// Converts to milliseconds
    var milliseconds: Int {
        return Int(self * 1000)
    }
    
    /// Converts to microseconds
    var microseconds: Int {
        return Int(self * 1_000_000)
    }
    
    /// Converts to nanoseconds
    var nanoseconds: Int {
        return Int(self * 1_000_000_000)
    }
}

// MARK: - UIColor Extensions

#if canImport(UIKit)
extension UIColor {
    
    /// Convenience initializer for hex colors
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
    
    /// Returns hex string representation
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
    
    /// Returns a lighter version of the color
    func lighter(by percentage: CGFloat = 0.2) -> UIColor {
        return adjustBrightness(by: abs(percentage))
    }
    
    /// Returns a darker version of the color
    func darker(by percentage: CGFloat = 0.2) -> UIColor {
        return adjustBrightness(by: -abs(percentage))
    }
    
    /// Adjusts brightness
    private func adjustBrightness(by percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return UIColor(
            hue: h,
            saturation: s,
            brightness: max(0, min(1, b + percentage)),
            alpha: a
        )
    }
    
    /// Returns complementary color
    var complementary: UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        let complementaryHue = h + 0.5 > 1.0 ? h - 0.5 : h + 0.5
        
        return UIColor(hue: complementaryHue, saturation: s, brightness: b, alpha: a)
    }
    
    /// Blends with another color
    func blended(with color: UIColor, ratio: CGFloat = 0.5) -> UIColor {
        let ratio = max(0, min(1, ratio))
        let inverseRatio = 1.0 - ratio
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(
            red: r1 * inverseRatio + r2 * ratio,
            green: g1 * inverseRatio + g2 * ratio,
            blue: b1 * inverseRatio + b2 * ratio,
            alpha: a1 * inverseRatio + a2 * ratio
        )
    }
    
    /// Random color generator
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
#endif

// MARK: - CGFloat Extensions

extension CGFloat {
    
    /// Converts degrees to radians
    var degreesToRadians: CGFloat {
        return self * .pi / 180
    }
    
    /// Converts radians to degrees
    var radiansToDegrees: CGFloat {
        return self * 180 / .pi
    }
    
    /// Clamps value between min and max
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.max(range.lowerBound, Swift.min(range.upperBound, self))
    }
    
    /// Rounds to specified decimal places
    func rounded(to places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// Returns absolute value
    var abs: CGFloat {
        return Swift.abs(self)
    }
    
    /// Checks if value is between two values
    func isBetween(_ min: CGFloat, and max: CGFloat) -> Bool {
        return self >= min && self <= max
    }
}

// MARK: - Double Extensions

extension Double {
    
    /// Converts degrees to radians
    var degreesToRadians: Double {
        return self * .pi / 180
    }
    
    /// Converts radians to degrees
    var radiansToDegrees: Double {
        return self * 180 / .pi
    }
    
    /// Rounds to specified decimal places
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// Returns absolute value
    var abs: Double {
        return Swift.abs(self)
    }
    
    /// Clamps value between min and max
    func clamped(to range: ClosedRange<Double>) -> Double {
        return Swift.max(range.lowerBound, Swift.min(range.upperBound, self))
    }
    
    /// Formats as currency
    func formatted(as currency: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    /// Formats as percentage
    var asPercentage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "0%"
    }
    
    /// Formats with ordinal suffix
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
    }
}

// MARK: - Int Extensions

extension Int {
    
    /// Formats with ordinal suffix
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    /// Returns factorial
    var factorial: Int {
        guard self >= 0 else { return 0 }
        return self <= 1 ? 1 : self * (self - 1).factorial
    }
    
    /// Checks if number is prime
    var isPrime: Bool {
        guard self > 1 else { return false }
        guard self > 3 else { return true }
        guard self % 2 != 0 && self % 3 != 0 else { return false }
        
        var i = 5
        while i * i <= self {
            if self % i == 0 || self % (i + 2) == 0 {
                return false
            }
            i += 6
        }
        return true
    }
    
    /// Checks if number is even
    var isEven: Bool {
        return self % 2 == 0
    }
    
    /// Checks if number is odd
    var isOdd: Bool {
        return !isEven
    }
    
    /// Returns digits of number
    var digits: [Int] {
        return String(self).compactMap { Int(String($0)) }
    }
    
    /// Returns sum of digits
    var digitSum: Int {
        return digits.reduce(0, +)
    }
    
    /// Converts to Roman numeral
    var romanNumeral: String {
        let values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        let literals = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        
        var result = ""
        var number = self
        
        for (index, value) in values.enumerated() {
            while number >= value {
                result += literals[index]
                number -= value
            }
        }
        
        return result
    }
    
    /// Returns times as string
    var times: String {
        switch self {
        case 1: return "once"
        case 2: return "twice"
        default: return "\(self) times"
        }
    }
    
    /// Executes closure n times
    func times(_ closure: () -> Void) {
        for _ in 0..<self {
            closure()
        }
    }
    
    /// Executes closure n times with index
    func times(_ closure: (Int) -> Void) {
        for i in 0..<self {
            closure(i)
        }
    }
}

// MARK: - Data Extensions

extension Data {
    
    /// Returns hex string representation
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Creates data from hex string
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        
        self = data
    }
    
    /// Returns pretty printed JSON string
    var prettyPrintedJSON: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return prettyPrintedString
    }
    
    /// Converts to dictionary
    var dictionary: [String: Any]? {
        return try? JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]
    }
    
    /// Converts to array
    var array: [Any]? {
        return try? JSONSerialization.jsonObject(with: self, options: []) as? [Any]
    }
}

// MARK: - URL Extensions

extension URL {
    
    /// Appends query parameters
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        
        var queryItems = components.queryItems ?? []
        queryItems.append(contentsOf: parameters.map { URLQueryItem(name: $0.key, value: $0.value) })
        components.queryItems = queryItems
        
        return components.url ?? self
    }
    
    /// Returns query parameters as dictionary
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return [:]
        }
        
        return Dictionary(uniqueKeysWithValues: queryItems.compactMap { item in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
    }
    
    /// Checks if URL is valid
    var isValid: Bool {
        return UIApplication.shared.canOpenURL(self)
    }
    
    /// Returns file size in bytes
    var fileSize: Int64 {
        let resourceValues = try? resourceValues(forKeys: [.fileSizeKey])
        return Int64(resourceValues?.fileSize ?? 0)
    }
    
    /// Returns creation date
    var creationDate: Date? {
        let resourceValues = try? resourceValues(forKeys: [.creationDateKey])
        return resourceValues?.creationDate
    }
    
    /// Returns modification date
    var modificationDate: Date? {
        let resourceValues = try? resourceValues(forKeys: [.contentModificationDateKey])
        return resourceValues?.contentModificationDate
    }
    
    /// Checks if URL is directory
    var isDirectory: Bool {
        let resourceValues = try? resourceValues(forKeys: [.isDirectoryKey])
        return resourceValues?.isDirectory ?? false
    }
    
    /// Checks if URL is hidden
    var isHidden: Bool {
        let resourceValues = try? resourceValues(forKeys: [.isHiddenKey])
        return resourceValues?.isHidden ?? false
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    
    /// Sets optional value for key
    func set<T>(_ value: T?, forKey key: String) where T: Codable {
        if let value = value {
            if let data = try? JSONEncoder().encode(value) {
                set(data, forKey: key)
            }
        } else {
            removeObject(forKey: key)
        }
    }
    
    /// Gets value for key
    func get<T>(_ type: T.Type, forKey key: String) -> T? where T: Codable {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    /// Checks if key exists
    func exists(key: String) -> Bool {
        return object(forKey: key) != nil
    }
    
    /// Removes all keys with prefix
    func removeAllKeys(withPrefix prefix: String) {
        let keys = dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
        keys.forEach { removeObject(forKey: $0) }
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    
    /// Returns app name
    var appName: String {
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
    
    /// Returns app version
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    /// Returns build number
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    /// Returns bundle identifier
    var bundleId: String {
        return bundleIdentifier ?? ""
    }
    
    /// Returns display name
    var displayName: String {
        return infoDictionary?["CFBundleDisplayName"] as? String ?? appName
    }
    
    /// Returns app icon name
    var appIconName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String] else {
            return nil
        }
        return iconFiles.last
    }
}

// MARK: - FileManager Extensions

extension FileManager {
    
    /// Returns documents directory URL
    var documentsDirectory: URL {
        return urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Returns caches directory URL
    var cachesDirectory: URL {
        return urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    /// Returns temporary directory URL
    var temporaryDirectory: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }
    
    /// Returns app support directory URL
    var applicationSupportDirectory: URL {
        return urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
    
    /// Creates directory if it doesn't exist
    func createDirectoryIfNeeded(at url: URL) throws {
        if !fileExists(atPath: url.path) {
            try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// Returns directory size in bytes
    func directorySize(at url: URL) -> Int64 {
        guard let enumerator = enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        
        for case let fileURL as URL in enumerator {
            let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey])
            totalSize += Int64(resourceValues?.fileSize ?? 0)
        }
        
        return totalSize
    }
    
    /// Clears directory contents
    func clearDirectory(at url: URL) throws {
        let contents = try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        for fileURL in contents {
            try removeItem(at: fileURL)
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    
    // Custom notification names for GlobalLingo
    static let translationCompleted = Notification.Name("translationCompleted")
    static let languageChanged = Notification.Name("languageChanged")
    static let voiceRecognitionStarted = Notification.Name("voiceRecognitionStarted")
    static let voiceRecognitionStopped = Notification.Name("voiceRecognitionStopped")
    static let offlineModeEnabled = Notification.Name("offlineModeEnabled")
    static let offlineModeDisabled = Notification.Name("offlineModeDisabled")
    static let cacheCleared = Notification.Name("cacheCleared")
    static let settingsChanged = Notification.Name("settingsChanged")
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
    static let qualityAssessmentCompleted = Notification.Name("qualityAssessmentCompleted")
}

// MARK: - Result Extensions

extension Result {
    
    /// Returns the value if success, nil otherwise
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the error if failure, nil otherwise
    var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
    /// Returns true if result is success
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns true if result is failure
    var isFailure: Bool {
        return !isSuccess
    }
    
    /// Transforms success value
    func mapValue<T>(_ transform: (Success) -> T) -> Result<T, Failure> {
        return map(transform)
    }
    
    /// Transforms error value
    func mapError<T>(_ transform: (Failure) -> T) -> Result<Success, T> {
        return mapError(transform)
    }
}

// MARK: - Optional Extensions

extension Optional {
    
    /// Returns true if optional has value
    var hasValue: Bool {
        return self != nil
    }
    
    /// Returns true if optional is nil
    var isNil: Bool {
        return self == nil
    }
    
    /// Unwraps optional or throws error
    func unwrap(or error: Error) throws -> Wrapped {
        guard let value = self else { throw error }
        return value
    }
    
    /// Unwraps optional or returns default value
    func unwrap(or defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
        return self ?? defaultValue()
    }
    
    /// Executes closure if optional has value
    func ifLet(_ closure: (Wrapped) -> Void) {
        if let value = self {
            closure(value)
        }
    }
    
    /// Executes closure if optional is nil
    func ifNil(_ closure: () -> Void) {
        if self == nil {
            closure()
        }
    }
}

// MARK: - Comparable Extensions

extension Comparable {
    
    /// Clamps value to range
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
    
    /// Checks if value is in range
    func isIn(range: ClosedRange<Self>) -> Bool {
        return range.contains(self)
    }
}

// MARK: - Collection Extensions

extension Collection {
    
    /// Returns true if collection is not empty
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    /// Returns second element if it exists
    var second: Element? {
        return dropFirst().first
    }
    
    /// Returns third element if it exists
    var third: Element? {
        return dropFirst(2).first
    }
    
    /// Returns second to last element if it exists
    var secondToLast: Element? {
        return dropLast().last
    }
    
    /// Safely accesses element at index
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Sequence Extensions

extension Sequence {
    
    /// Groups elements by key path
    func grouped<Key: Hashable>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] {
        return Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }
    
    /// Returns unique elements
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
    
    /// Counts elements matching predicate
    func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        return try filter(predicate).count
    }
}

extension Sequence where Element: Hashable {
    
    /// Returns unique elements preserving order
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// MARK: - Logger Extensions

extension Logger {
    
    /// Logs with GlobalLingo context
    static let globalLingo = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GlobalLingo", category: "GlobalLingo")
    
    /// Logs translation events
    static let translation = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GlobalLingo", category: "Translation")
    
    /// Logs voice recognition events
    static let voiceRecognition = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GlobalLingo", category: "VoiceRecognition")
    
    /// Logs networking events
    static let networking = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GlobalLingo", category: "Networking")
    
    /// Logs security events
    static let security = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GlobalLingo", category: "Security")
    
    /// Logs performance events
    static let performance = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GlobalLingo", category: "Performance")
    
    /// Logs analytics events
    static let analytics = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GlobalLingo", category: "Analytics")
}

// MARK: - Error Extensions

extension Error {
    
    /// Returns localized description with fallback
    var safeLocalizedDescription: String {
        return localizedDescription.isEmpty ? "Unknown error occurred" : localizedDescription
    }
    
    /// Returns error code if available
    var code: Int? {
        return (self as NSError).code
    }
    
    /// Returns error domain if available
    var domain: String? {
        return (self as NSError).domain
    }
    
    /// Returns user info if available
    var userInfo: [String: Any]? {
        return (self as NSError).userInfo
    }
}

// MARK: - Combine Extensions

#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
extension Publisher {
    
    /// Assigns to weak object to prevent retain cycles
    func assignWeak<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on object: Root
    ) -> AnyCancellable {
        return sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
    /// Executes on main thread
    func receiveOnMain() -> Publishers.ReceiveOn<Self, DispatchQueue> {
        return receive(on: DispatchQueue.main)
    }
    
    /// Subscribes on background queue
    func subscribeOnBackground() -> Publishers.SubscribeOn<Self, DispatchQueue> {
        return subscribe(on: DispatchQueue.global(qos: .background))
    }
    
    /// Ignores errors and provides default value
    func replaceErrorWithDefault(_ defaultValue: Output) -> Publishers.ReplaceError<Self> {
        return replaceError(with: defaultValue)
    }
}
#endif
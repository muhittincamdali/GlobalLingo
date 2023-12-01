import Foundation
public protocol SecurityManagerProtocol { func encryptData(_ data: Data, withKey key: String) async throws -> Data }

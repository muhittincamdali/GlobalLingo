import Foundation

/// Texts the app builds outside SwiftUI views.
enum Messages {
    static func syncFailed() -> String {
        NSLocalizedString("sync.failed", comment: "Shown when the shelf could not be synced")
    }

    static func syncRetry() -> String {
        NSLocalizedString("sync.retry", comment: "Button that syncs again")
    }

    /// Looks a status up by the name the server sends, e.g. "IDLE".
    static func status(_ name: String) -> String {
        NSLocalizedString("status.\(name)".localizedLowercase, comment: "")
    }
}

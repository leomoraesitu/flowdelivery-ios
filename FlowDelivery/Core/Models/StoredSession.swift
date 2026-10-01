import Foundation

/// On-disk format of a persisted session. Separate from `UserSession` so the
/// persistence contract can evolve (and be versioned) independently.
struct StoredSession: Codable, Equatable {
    static let currentVersion = 1

    let version: Int
    let userID: UUID
    let accessToken: String

    init(
        version: Int = StoredSession.currentVersion,
        userID: UUID,
        accessToken: String
    ) {
        self.version = version
        self.userID = userID
        self.accessToken = accessToken
    }

    init(_ session: UserSession) {
        self.init(userID: session.userID, accessToken: session.accessToken)
    }

    var session: UserSession {
        UserSession(userID: userID, accessToken: accessToken)
    }
}

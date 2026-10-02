import Foundation

nonisolated struct UserSession: Equatable, Sendable, Codable {
    let userID: UUID
    let accessToken: String
}

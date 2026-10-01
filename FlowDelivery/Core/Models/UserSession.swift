import Foundation

struct UserSession: Equatable, Sendable, Codable {
    let userID: UUID
    let accessToken: String
}

import Foundation

protocol AuthRepository {
    func login() -> UserSession?
    func logout()
    /// A real backend would validate the stored session (token still valid,
    /// identity matches). The fake accepts any non-empty token as-is.
    func restoreSession(_ session: UserSession) -> UserSession?
}

final class FakeAuthRepository: AuthRepository {
    func login() -> UserSession? {
        UserSession(userID: UUID(), accessToken: UUID().uuidString)
    }

    func logout() {}

    func restoreSession(_ session: UserSession) -> UserSession? {
        session.accessToken.isEmpty ? nil : session
    }
}

import Foundation

protocol AuthRepository {
    func login() -> UserSession?
    func logout()
    func restoreSession() -> UserSession?
}

final class FakeAuthRepository: AuthRepository {
    func login() -> UserSession? {
        UserSession(
            userID: UUID(),
            accessToken: UUID().uuidString
        )
    }

    func logout() {}

    func restoreSession() -> UserSession? {
        nil
    }
}

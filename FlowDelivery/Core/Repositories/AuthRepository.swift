import Foundation

protocol AuthRepository {
    func login() -> UserSession?
    func logout()
    func restoreSession() -> UserSession?
}

final class FakeAuthRepository: AuthRepository {
    func login() -> UserSession? {
        UserSession(
            userID: UUID()
        )
    }

    func logout() {}

    func restoreSession() -> UserSession? {
        nil
    }
}

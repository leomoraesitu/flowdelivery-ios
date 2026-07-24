import Foundation

protocol AuthRepository {
    func login() -> UserSession?
    func logout()
}

final class FakeAuthRepository: AuthRepository {
    func login() -> UserSession? {
        UserSession(
            userID: UUID()
        )
    }

    func logout() {}
}

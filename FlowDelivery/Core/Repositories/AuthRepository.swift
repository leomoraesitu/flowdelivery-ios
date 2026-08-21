import Foundation

protocol AuthRepository {
    func login() -> UserSession?
    func logout()
    /// O backend real validaria o token e devolveria a identidade do
    /// usuário. Aqui o userID é gerado a cada restauração, porque o
    /// TokenStore persiste apenas o access token.
    func restoreSession(
        accessToken: String
    ) -> UserSession?
}

final class FakeAuthRepository: AuthRepository {
    func login() -> UserSession? {
        UserSession(
            userID: UUID(),
            accessToken: UUID().uuidString
        )
    }

    func logout() {}

    func restoreSession(
        accessToken: String
    ) -> UserSession? {
        guard !accessToken.isEmpty else {
            return nil
        }

        return UserSession(
            userID: UUID(),
            accessToken: accessToken
        )
    }
}

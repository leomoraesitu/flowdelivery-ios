final class AuthService {
    private let sessionStore: SessionStore
    private let repository: AuthRepository
    private let tokenStore: TokenStore

    init(
        repository: AuthRepository,
        tokenStore: TokenStore,
        sessionStore: SessionStore
    ) {
        self.repository = repository
        self.tokenStore = tokenStore
        self.sessionStore = sessionStore
    }

    func login() {
        guard let session = repository.login() else {
            return
        }

        sessionStore.login(
            with: session
        )
    }

    func logout() {
        repository.logout()

        sessionStore.logout()
    }

    func restoreSession() {
        guard let session = repository.restoreSession() else {
            return
        }

        sessionStore.login(with: session)
    }
}

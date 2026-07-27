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

    func login() throws {
        guard let session = repository.login() else {
            return
        }
        try tokenStore.save(
            session.accessToken
        )

        sessionStore.login(
            with: session
        )
    }

    func logout() throws {
        repository.logout()

        try tokenStore.delete()

        sessionStore.logout()
    }

    func restoreSession() throws {
        guard let accessToken = try tokenStore.load() else {
            return
        }

        guard let session = repository.restoreSession(
            accessToken: accessToken
        ) else {
            return
        }

        sessionStore.login(
            with: session
        )
    }
}

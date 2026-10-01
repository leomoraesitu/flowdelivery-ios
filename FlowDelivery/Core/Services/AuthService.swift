final class AuthService {
    private let sessionStore: SessionStore
    private let repository: AuthRepository
    private let sessionCredentialStore: SessionCredentialStore

    init(
        repository: AuthRepository,
        sessionCredentialStore: SessionCredentialStore,
        sessionStore: SessionStore
    ) {
        self.repository = repository
        self.sessionCredentialStore = sessionCredentialStore
        self.sessionStore = sessionStore
    }

    func login() throws {
        guard let session = repository.login() else { return }
        // Persist before publishing: if saving fails, the app must not look
        // logged in for a session that will not survive a relaunch.
        try sessionCredentialStore.save(session)
        sessionStore.login(with: session)
    }

    func logout() throws {
        // Always clear in-memory state, even if removing the credential fails.
        defer { sessionStore.logout() }

        repository.logout()
        try sessionCredentialStore.delete()
    }

    func restoreSession() throws {
        guard let stored = try sessionCredentialStore.load() else { return }

        guard let restored = repository.restoreSession(stored) else {
            // The backend refused the stored session: don't keep a dead credential.
            try sessionCredentialStore.delete()
            return
        }
        sessionStore.login(with: restored)
    }
}

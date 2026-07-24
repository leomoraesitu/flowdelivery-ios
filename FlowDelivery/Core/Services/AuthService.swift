import Foundation

final class AuthService {
    private let sessionStore: SessionStore
    private let repository: AuthRepository

    init(
        repository: AuthRepository,
        sessionStore: SessionStore
    ) {
        self.repository = repository
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
}

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
        let authenticated = repository.login()

        guard authenticated else {
            return
        }

        sessionStore.login()
    }

    func logout() {
        repository.logout()

        sessionStore.logout()
    }
}

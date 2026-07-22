import Foundation

final class AuthService {
    private let sessionStore: SessionStore

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    func login() {
        sessionStore.login()
    }

    func logout() {
        sessionStore.logout()
    }
}

import Observation

@Observable
final class RootViewModel {
    private let sessionStore: SessionStore
    private let authService: AuthService

    init(
        sessionStore: SessionStore,
        authService: AuthService
    ) {
        self.sessionStore = sessionStore
        self.authService = authService
    }

    var isLoggedIn: Bool {
        sessionStore.isLoggedIn
    }

    func authenticationButtonTapped() {
        if sessionStore.isLoggedIn {
            sessionStore.logout()
        } else {
            sessionStore.login()
        }
    }
}

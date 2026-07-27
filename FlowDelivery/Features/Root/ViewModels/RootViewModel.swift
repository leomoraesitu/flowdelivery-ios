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

    func authenticationButtonTapped() throws {
        if sessionStore.isLoggedIn {
            try authService.logout()
        } else {
            try authService.login()
        }
    }
}

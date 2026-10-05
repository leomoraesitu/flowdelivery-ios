import Observation

@Observable
final class AppStartupViewModel {
    enum StartupState: Equatable {
        case idle
        case loading
        case ready
    }

    private let authService: AuthService

    private(set) var state: StartupState = .idle

    init(authService: AuthService) {
        self.authService = authService
    }

    func start() {
        state = .loading

        do {
            try authService.restoreSession()
        } catch {
            // A Keychain read/delete failure (e.g. device locked) just means
            // there is no session to restore: SessionStore stays logged out
            // and the app falls through to the login screen, same as a clean
            // "no stored session" outcome.
        }

        state = .ready
    }
}

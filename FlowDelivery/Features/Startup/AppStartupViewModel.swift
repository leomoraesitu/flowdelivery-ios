import Observation

@Observable
final class AppStartupViewModel {
    enum StartupState: Equatable {
        case idle
        case loading
        case ready
        case failed
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
            state = .ready
        } catch {
            state = .failed
        }
    }
}

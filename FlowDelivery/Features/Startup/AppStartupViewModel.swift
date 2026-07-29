import Observation

@Observable
final class AppStartupViewModel {
    enum StartupState: Equatable {
        case idle
        case loading
        case ready
        case failed
    }

    private let container: AppContainer

    private(set) var state: StartupState = .idle

    init(container: AppContainer) {
        self.container = container
    }

    func start() {
        state = .loading

        do {
            try container.restoreSession()
            state = .ready
        } catch {
            state = .failed
        }
    }
}

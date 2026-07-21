import Observation

@Observable
final class RootViewModel {
    private let sessionStore: SessionStore

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    var isLoggedIn: Bool {
        sessionStore.isLoggedIn
    }
}

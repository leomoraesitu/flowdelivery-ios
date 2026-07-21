import Observation

@Observable
final class AppContainer {
    let sessionStore: SessionStore

    let rootViewModel: RootViewModel

    init() {
        let sessionStore = SessionStore()

        self.sessionStore = sessionStore

        rootViewModel = RootViewModel(
            sessionStore: sessionStore
        )
    }
}

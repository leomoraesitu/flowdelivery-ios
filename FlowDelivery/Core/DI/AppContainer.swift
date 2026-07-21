import Observation

@Observable
final class AppContainer {

    let sessionStore: SessionStore

    let rootViewModel: RootViewModel

    init() {
        let sessionStore = SessionStore()

        self.sessionStore = sessionStore

        self.rootViewModel = RootViewModel(
            sessionStore: sessionStore
        )
    }
}

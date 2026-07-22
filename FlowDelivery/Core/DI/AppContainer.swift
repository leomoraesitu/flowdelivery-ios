import Observation

@Observable
final class AppContainer {
    let sessionStore: SessionStore
    let authService: AuthService

    let rootViewModel: RootViewModel

    init() {
        let sessionStore = SessionStore()
        let authService = AuthService()

        self.sessionStore = sessionStore
        self.authService = authService
        rootViewModel = RootViewModel(
            sessionStore: sessionStore,
            authService: authService
        )
    }
}

import Observation

@Observable
final class AppContainer {
    let sessionStore: SessionStore
    let authService: AuthService

    let rootViewModel: RootViewModel

    init() {
        let sessionStore = SessionStore()
        let authRepository = FakeAuthRepository()

        let authService = AuthService(
            repository: authRepository,
            sessionStore: sessionStore
        )

        self.sessionStore = sessionStore
        self.authService = authService
        rootViewModel = RootViewModel(
            sessionStore: sessionStore,
            authService: authService
        )
    }
}

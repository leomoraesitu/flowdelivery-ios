import Observation

@Observable
final class AppContainer {
    let sessionStore: SessionStore
    let authService: AuthService
    let rootViewModel: RootViewModel
    let homeViewModel: HomeViewModel

    init() {
        let sessionStore = SessionStore()
        let authRepository = FakeAuthRepository()
        let tokenStore = FakeTokenStore()

        let authService = AuthService(
            repository: authRepository,
            tokenStore: tokenStore,
            sessionStore: sessionStore
        )

        self.sessionStore = sessionStore
        self.authService = authService
        rootViewModel = RootViewModel(
            sessionStore: sessionStore,
            authService: authService
        )
        homeViewModel = HomeViewModel()
    }

    func restoreSession() throws {
        try authService.restoreSession()
    }
}

import Observation

@Observable
final class AppContainer {
    let sessionStore: SessionStore
    let authService: AuthService
    let rootViewModel: RootViewModel
    let homeViewModel: HomeViewModel
    let restaurantRepository: RestaurantRepository

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
        restaurantRepository = FakeRestaurantRepository()
        homeViewModel = HomeViewModel(
            repository: restaurantRepository
        )
    }

    func restoreSession() throws {
        try authService.restoreSession()
    }
}

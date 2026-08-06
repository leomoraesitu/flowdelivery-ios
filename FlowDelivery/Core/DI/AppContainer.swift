import Foundation
import Observation

@MainActor
@Observable
final class AppContainer {
    let sessionStore: SessionStore
    let cartStore: CartStore
    let authService: AuthService
    let rootViewModel: RootViewModel
    let homeViewModel: HomeViewModel
    let restaurantRepository: RestaurantRepository

    init() {
        let sessionStore = SessionStore()
        let cartStore = CartStore()
        let authRepository = FakeAuthRepository()
        let tokenStore = FakeTokenStore()
        let restaurantRepository = FakeRestaurantRepository()

        let authService = AuthService(
            repository: authRepository,
            tokenStore: tokenStore,
            sessionStore: sessionStore
        )

        self.sessionStore = sessionStore
        self.cartStore = cartStore
        self.authService = authService
        self.restaurantRepository = restaurantRepository

        rootViewModel = RootViewModel(
            sessionStore: sessionStore,
            authService: authService
        )

        homeViewModel = HomeViewModel(
            repository: restaurantRepository
        )
    }

    func makeRestaurantDetailsViewModel(
        restaurantID: UUID
    ) -> RestaurantDetailsViewModel {
        RestaurantDetailsViewModel(
            restaurantID: restaurantID,
            repository: FakeRestaurantDetailsRepository(),
            cartStore: cartStore
        )
    }

    func restoreSession() throws {
        try authService.restoreSession()
    }
}

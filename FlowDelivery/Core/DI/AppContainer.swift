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
    let orderRepository: OrderRepository

    init() {
        let sessionStore = SessionStore()
        let cartStore = CartStore()
        let authRepository = FakeAuthRepository()
        let tokenStore = FakeTokenStore()
        let restaurantRepository = FakeRestaurantRepository()
        let orderRepository = FakeOrderRepository()

        let authService = AuthService(
            repository: authRepository,
            tokenStore: tokenStore,
            sessionStore: sessionStore
        )

        self.sessionStore = sessionStore
        self.cartStore = cartStore
        self.authService = authService
        self.restaurantRepository = restaurantRepository
        self.orderRepository = orderRepository

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

    func makeCartViewModel() -> CartViewModel {
        CartViewModel(
            cartStore: cartStore
        )
    }

    func makeCheckoutViewModel() -> CheckoutViewModel {
        CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: orderRepository
        )
    }

    func makeOrderHistoryViewModel() -> OrderHistoryViewModel {
        OrderHistoryViewModel(
            repository: orderRepository
        )
    }

    func makeOrderDetailsViewModel(
        orderID: UUID
    ) -> OrderDetailsViewModel {
        OrderDetailsViewModel(
            orderID: orderID,
            repository: orderRepository
        )
    }
}

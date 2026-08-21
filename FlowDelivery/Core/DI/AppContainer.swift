import Foundation
import Observation

private enum UITestLaunchArgument {
    static let failingOrderRepository =
        "-ui-testing-failing-order-repository"
    static let failOnceOrderRepository =
        "-ui-testing-fail-once-order-repository"
    static let failOnceOrderHistoryRepository =
        "-ui-testing-fail-once-order-history-repository"
    static let failOnceOrderDetailsRepository =
        "-ui-testing-fail-once-order-details-repository"
    static let orderHistoryFixtureRepository =
        "-ui-testing-order-history-fixture-repository"
    static let inMemoryTokenStore =
        "-ui-testing-in-memory-token-store"
}

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
        let tokenStore = Self.makeTokenStore()
        let restaurantRepository = FakeRestaurantRepository()
        let orderRepository = Self.makeOrderRepository()

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

    private static func makeTokenStore() -> TokenStore {
        if ProcessInfo.processInfo.arguments.contains(
            UITestLaunchArgument.inMemoryTokenStore
        ) {
            FakeTokenStore()
        } else {
            KeychainTokenStore()
        }
    }

    private static func makeOrderRepository() -> OrderRepository {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains(
            UITestLaunchArgument.failingOrderRepository
        ) {
            return FailingOrderRepository()
        }

        if arguments.contains(
            UITestLaunchArgument.failOnceOrderRepository
        ) {
            return FailOnceOrderRepository()
        }

        if arguments.contains(
            UITestLaunchArgument.failOnceOrderHistoryRepository
        ) {
            return FailOnceOrderHistoryRepository()
        }

        if arguments.contains(
            UITestLaunchArgument.failOnceOrderDetailsRepository
        ) {
            return FailOnceOrderDetailsRepository()
        }

        if arguments.contains(
            UITestLaunchArgument.orderHistoryFixtureRepository
        ) {
            return OrderHistoryFixtureRepository()
        }

        return FakeOrderRepository()
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

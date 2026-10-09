import Foundation
import Observation

private nonisolated enum UITestLaunchArgument {
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
    static let inMemorySessionStore =
        "-ui-testing-in-memory-session-store"
    static let failingDeleteSessionStore =
        "-ui-testing-failing-delete-session-store"
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

    init(credentialStore: SessionCredentialStore = AppContainer.makeCredentialStore()) {
        let sessionStore = SessionStore()
        let cartStore = CartStore()
        let authRepository = FakeAuthRepository()
        let restaurantRepository = FakeRestaurantRepository()
        let orderRepository = Self.makeOrderRepository()

        let authService = AuthService(
            repository: authRepository,
            sessionCredentialStore: credentialStore,
            sessionStore: sessionStore
        )

        self.sessionStore = sessionStore
        self.cartStore = cartStore
        self.authService = authService
        self.restaurantRepository = restaurantRepository
        self.orderRepository = orderRepository

        rootViewModel = RootViewModel(
            sessionStore: sessionStore,
            authService: authService,
            cartStore: cartStore
        )

        homeViewModel = HomeViewModel(
            repository: restaurantRepository
        )
    }

    private nonisolated static func makeCredentialStore() -> SessionCredentialStore {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains(
            UITestLaunchArgument.failingDeleteSessionStore
        ) {
            return FailingDeleteSessionCredentialStore()
        }

        if arguments.contains(
            UITestLaunchArgument.inMemorySessionStore
        ) {
            return FakeSessionCredentialStore()
        }

        return KeychainSessionStore()
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

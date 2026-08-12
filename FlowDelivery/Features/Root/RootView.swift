import SwiftUI

struct RootView: View {
    let viewModel: RootViewModel
    let homeViewModel: HomeViewModel
    let appContainer: AppContainer

    var body: some View {
        NavigationStack {
            content
                .padding(AppSpacing.large)
                .navigationTitle("FlowDelivery")
                .navigationDestination(
                    for: AppRoute.self
                ) { route in
                    destination(
                        for: route
                    )
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.rootState {
        case .authenticated:
            HomeView(
                viewModel: homeViewModel,
                appContainer: appContainer
            )

        case .unauthenticated:
            AuthenticationView(
                viewModel: viewModel.authenticationViewModel
            )
        }
    }

    @ViewBuilder
    private func destination(
        for route: AppRoute
    ) -> some View {
        switch route {
        case .orderHistory:
            OrderHistoryView(
                viewModel: appContainer
                    .makeOrderHistoryViewModel()
            )

        case let .orderDetails(orderID):
            OrderDetailsView(
                viewModel: appContainer
                    .makeOrderDetailsViewModel(
                        orderID: orderID
                    )
            )

        case let .restaurantDetails(restaurantID):
            RestaurantDetailsView(
                viewModel: appContainer
                    .makeRestaurantDetailsViewModel(
                        restaurantID: restaurantID
                    )
            )

        case .cart:
            CartView(
                viewModel: appContainer
                    .makeCartViewModel()
            )

        case .checkout:
            CheckoutView(
                viewModel: appContainer
                    .makeCheckoutViewModel()
            )
        }
    }
}

#Preview {
    let container = AppContainer()

    RootView(
        viewModel: container.rootViewModel,
        homeViewModel: container.homeViewModel,
        appContainer: container
    )
}

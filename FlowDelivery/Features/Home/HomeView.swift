import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel
    let appContainer: AppContainer

    private var cartAccessibilityValue: String {
        let itemCount = appContainer.cartStore.itemCount

        switch itemCount {
        case 0:
            return "Vazio"

        case 1:
            return "1 item"

        default:
            return "\(itemCount) itens"
        }
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()

            case let .loaded(content):
                List(content.restaurants) { restaurant in
                    NavigationLink {
                        RestaurantDetailsView(
                            viewModel: appContainer
                                .makeRestaurantDetailsViewModel(
                                    restaurantID: restaurant.id
                                )
                        )
                    } label: {
                        RestaurantRowView(
                            model: restaurant
                        )
                    }
                }
                .refreshable {
                    await viewModel.load()
                }

            case let .error(error):
                ContentUnavailableView {
                    Label(
                        error.message,
                        systemImage: "wifi.exclamationmark"
                    )
                } actions: {
                    Button("Tentar novamente") {
                        Task {
                            await viewModel.load()
                        }
                    }
                }

            case .empty:
                ContentUnavailableView(
                    "Nenhum restaurante encontrado",
                    systemImage: "fork.knife.circle"
                )
            }
        }
        .toolbar {
            ToolbarItem(
                placement: .topBarTrailing
            ) {
                NavigationLink {
                    CartView()
                } label: {
                    CartBadgeView(
                        itemCount: appContainer.cartStore.itemCount
                    )
                }
                .accessibilityLabel("Carrinho")
                .accessibilityValue(
                    Text(cartAccessibilityValue)
                )
            }
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}

extension HomeViewModel.HomeError {
    var message: LocalizedStringKey {
        switch self {
        case .loadFailed:
            "Não foi possível carregar os restaurantes."
        }
    }
}

#Preview {
    let container = AppContainer()
    HomeView(
        viewModel: HomeViewModel(
            repository: FakeRestaurantRepository()
        ),
        appContainer: container
    )
}

#Preview("Empty") {
    let container = AppContainer()
    let viewModel = HomeViewModel(
        repository: EmptyRestaurantRepository()
    )
    HomeView(
        viewModel: viewModel,
        appContainer: container
    )
}

#Preview("Error") {
    let container = AppContainer()
    let viewModel = HomeViewModel(
        repository: FailingRestaurantRepository()
    )

    HomeView(
        viewModel: viewModel,
        appContainer: container
    )
}

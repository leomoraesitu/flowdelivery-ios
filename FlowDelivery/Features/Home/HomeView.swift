import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()

            case let .loaded(content):
                List(content.restaurants) { restaurant in
                    NavigationLink {
                        RestaurantDetailsView(
                            viewModel: RestaurantDetailsViewModel(
                                restaurantID: restaurant.id,
                                repository: FakeRestaurantDetailsRepository()
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
    HomeView(
        viewModel: HomeViewModel(
            repository: FakeRestaurantRepository()
        )
    )
}

#Preview("Empty") {
    let viewModel = HomeViewModel(
        repository: EmptyRestaurantRepository()
    )

    HomeView(
        viewModel: viewModel
    )
}

#Preview("Error") {
    let viewModel = HomeViewModel(
        repository: FailingRestaurantRepository()
    )

    HomeView(
        viewModel: viewModel
    )
}

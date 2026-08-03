import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()

            case let .loaded(restaurants):
                List(restaurants) { restaurant in
                    Text(restaurant.name)
                }

            case let .error(error):
                Text(error.message)

            case .empty:
                ContentUnavailableView(
                    "Nenhum restaurante encontrado",
                    systemImage: "fork.knife.circle"
                )
            }
        }
        .task {
            await viewModel.load()
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

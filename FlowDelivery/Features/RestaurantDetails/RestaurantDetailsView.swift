import SwiftUI

struct RestaurantDetailsView: View {
    let viewModel: RestaurantDetailsViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                ProgressView()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )

            case let .loaded(restaurant):
                Text(restaurant.name)

            case let .error(error):
                ContentUnavailableView {
                    Label(
                        "Não foi possível carregar o restaurante",
                        systemImage: "wifi.exclamationmark"
                    )
                } description: {
                    Text(error.message)
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .navigationTitle("Restaurant")
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailsView(
            viewModel: RestaurantDetailsViewModel(
                restaurantID: UUID(),
                repository: FakeRestaurantDetailsRepository()
            )
        )
    }
}

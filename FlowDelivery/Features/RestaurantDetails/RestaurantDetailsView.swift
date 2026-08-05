import SwiftUI

struct RestaurantDetailsView: View {
    let viewModel: RestaurantDetailsViewModel

    var body: some View {
        content
            .task {
                await viewModel.load()
            }
            .navigationTitle("Restaurante")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

        case let .loaded(content):
            ScrollView {
                VStack(
                    spacing: AppSpacing.large
                ) {
                    RestaurantDetailsHeaderView(
                        content: content
                    )

                    Divider()

                    RestaurantMenuView(
                        menu: content.menu
                    )
                }
                .padding(AppSpacing.large)
            }

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

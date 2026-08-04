import SwiftUI

struct RestaurantDetailsView: View {
    let viewModel: RestaurantDetailsViewModel

    var body: some View {
        content
            .task {
                await viewModel.load()
            }
            .navigationTitle("Restaurant")
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
            loadedContent(content)

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

    private func loadedContent(
        _ content: RestaurantDetailsContent
    ) -> some View {
        VStack(
            spacing: AppSpacing.large
        ) {
            AsyncImage(
                url: content.imageURL
            ) { phase in
                switch phase {
                case .empty:
                    ProgressView()

                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    Image(systemName: "photo")

                @unknown default:
                    EmptyView()
                }
            }
            .frame(
                width: 200,
                height: 200
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.large
                )
            )

            Text(content.title)

            HStack {
                Label(
                    content.rating,
                    systemImage: "star.fill"
                )

                Spacer()

                Text(content.deliveryTime)

                Spacer()

                Text(content.deliveryFee)
            }

            .foregroundStyle(.secondary)
        }
        .padding(AppSpacing.large)
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

import SwiftUI

struct RestaurantDetailsHeaderView: View {
    let content: RestaurantDetailsContent

    var body: some View {
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
                .font(AppTypography.title)

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
            .font(AppTypography.body)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RestaurantDetailsHeaderView(
        content: RestaurantDetailsContent(
            restaurant: Restaurant(
                id: UUID(),
                name: "Pizzaria Itália",
                imageURL: URL(
                    string: "https://picsum.photos/300"
                ),
                rating: 4.8,
                deliveryTime: 30,
                deliveryFee: Decimal(
                    string: "5.99"
                )!,
                menu: [
                    MenuItem(
                        id: UUID(),
                        name: "Pizza Margherita",
                        description: "Molho de tomate, mussarela e manjericão.",
                        price: Decimal(string: "49.90")!,
                        imageURL: nil
                    ),
                    MenuItem(
                        id: UUID(),
                        name: "Pizza Calabresa",
                        description: "Calabresa, cebola e mussarela.",
                        price: Decimal(string: "54.90")!,
                        imageURL: nil
                    )
                ]
            )
        )
    )
}

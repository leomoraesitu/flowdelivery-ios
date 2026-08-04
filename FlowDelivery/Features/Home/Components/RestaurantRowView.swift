import SwiftUI

struct RestaurantRowView: View {
    let model: RestaurantRowModel

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            AsyncImage(url: model.imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()

                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(AppSpacing.large)
                        .foregroundStyle(.secondary)

                @unknown default:
                    EmptyView()
                }
            }
            .frame(
                width: AppIconSize.restaurantImage,
                height: AppIconSize.restaurantImage
            )
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(model.title)
                    .font(.headline)

                HStack {
                    Label(
                        model.rating,
                        systemImage: "star.fill"
                    )

                    Spacer()

                    Text(model.deliveryTime)

                    Spacer()

                    Text(
                        model.deliveryFee
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppSpacing.small)
    }
}

#Preview {
    RestaurantRowView(
        model: RestaurantRowModel(
            restaurant: Restaurant(
                id: UUID(),
                name: "Pizzaria Itália",
                imageURL: URL(
                    string: "https://picsum.photos/120"
                ),
                rating: 4.8,
                deliveryTime: 30,
                deliveryFee: Decimal(string: "5.99")!,
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

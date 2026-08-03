import SwiftUI

struct RestaurantRowView: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            AsyncImage(url: restaurant.imageURL) { phase in
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
                        .padding(20)
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
                Text(restaurant.name)
                    .font(.headline)

                HStack {
                    Label(
                        restaurant.rating.formatted(
                            .number.precision(.fractionLength(1))
                        ),
                        systemImage: "star.fill"
                    )

                    Spacer()

                    Text("\(restaurant.deliveryTime) min")

                    Spacer()

                    Text(
                        restaurant.deliveryFee,
                        format: .currency(code: "BRL")
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
        restaurant: Restaurant(
            id: UUID(),
            name: "Pizzaria Itália",
            imageURL: URL(
                string: "https://picsum.photos/120"
            ),
            rating: 4.8,
            deliveryTime: 30,
            deliveryFee: Decimal(string: "5.99")!
        )
    )
}

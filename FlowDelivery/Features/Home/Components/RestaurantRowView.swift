import SwiftUI

struct RestaurantRowView: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
        .padding(.vertical, 8)
    }
}

#Preview {
    RestaurantRowView(
        restaurant: Restaurant(
            id: UUID(),
            name: "Pizzaria Itália",
            rating: 4.8,
            deliveryTime: 30,
            deliveryFee: Decimal(string: "5.99")!
        )
    )
}

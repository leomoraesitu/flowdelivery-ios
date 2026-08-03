import Foundation

struct RestaurantRowModel: Identifiable, Equatable {
    let id: UUID

    let title: String

    let imageURL: URL?

    let rating: String

    let deliveryTime: String

    let deliveryFee: String
}

extension RestaurantRowModel {
    init(restaurant: Restaurant) {
        id = restaurant.id

        title = restaurant.name

        imageURL = restaurant.imageURL

        rating = restaurant.rating.formatted(
            .number.precision(.fractionLength(1))
        )

        deliveryTime =
            "\(restaurant.deliveryTime) min"

        deliveryFee =
            restaurant.deliveryFee.formatted(
                .currency(code: "BRL")
            )
    }
}

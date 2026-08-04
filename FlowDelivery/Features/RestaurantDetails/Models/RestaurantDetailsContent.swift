import Foundation

struct RestaurantDetailsContent: Equatable {
    let title: String

    let imageURL: URL?

    let rating: String

    let deliveryTime: String

    let deliveryFee: String

    let menu: [MenuItemContent]
}

extension RestaurantDetailsContent {
    init(
        restaurant: Restaurant
    ) {
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

        menu = restaurant.menu.map {
            MenuItemContent(menuItem: $0)
        }
    }
}

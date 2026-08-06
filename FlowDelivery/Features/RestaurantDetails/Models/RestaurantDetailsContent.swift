import Foundation

struct RestaurantDetailsContent: Equatable {
    let title: String
    let imageURL: URL?
    let rating: String
    let deliveryTime: String
    let deliveryFee: String
    let menu: [MenuItemContent]
    private let restaurant: Restaurant
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
        self.restaurant = restaurant
    }

    func menuItem(
        id: UUID
    ) -> MenuItem? {
        restaurant.menu.first {
            $0.id == id
        }
    }
}

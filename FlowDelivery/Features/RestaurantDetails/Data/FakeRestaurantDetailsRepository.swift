import Foundation

struct FakeRestaurantDetailsRepository: RestaurantDetailsRepository {
    private enum MenuItemID {
        static let margherita = UUID()
        static let calabresa = UUID()
    }

    func fetchRestaurant(
        id: UUID
    ) async throws -> Restaurant {
        Restaurant(
            id: id,
            name: "Pizzaria Itália",
            imageURL: URL(
                string: "https://picsum.photos/300"
            ),
            rating: 4.8,
            deliveryTime: 30,
            deliveryFee: Decimal(string: "5.99")!,
            menu: [
                MenuItem(
                    id: MenuItemID.margherita,
                    name: "Pizza Margherita",
                    description: "Molho de tomate, mussarela e manjericão.",
                    price: Decimal(string: "49.90")!,
                    imageURL: nil
                ),
                MenuItem(
                    id: MenuItemID.calabresa,
                    name: "Pizza Calabresa",
                    description: "Calabresa, cebola e mussarela.",
                    price: Decimal(string: "54.90")!,
                    imageURL: nil
                )
            ]
        )
    }
}

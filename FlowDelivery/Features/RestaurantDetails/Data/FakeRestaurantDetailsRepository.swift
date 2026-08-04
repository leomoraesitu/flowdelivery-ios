import Foundation

struct FakeRestaurantDetailsRepository: RestaurantDetailsRepository {
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
            deliveryFee: Decimal(string: "5.99")!
        )
    }
}

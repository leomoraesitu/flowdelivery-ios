import Foundation

struct FakeRestaurantRepository: RestaurantRepository {
    func fetchRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(
                id: UUID(),
                name: "Pizzaria Itália",
                rating: 4.8,
                deliveryTime: 30,
                deliveryFee: Decimal(string: "5.99")!
            ),
            Restaurant(
                id: UUID(),
                name: "Burger House",
                rating: 4.5,
                deliveryTime: 20,
                deliveryFee: Decimal(string: "3.99")!
            )
        ]
    }
}

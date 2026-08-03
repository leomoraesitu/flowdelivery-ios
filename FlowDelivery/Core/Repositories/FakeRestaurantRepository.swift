import Foundation

struct FakeRestaurantRepository: RestaurantRepository {
    func fetchRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(
                id: UUID(),
                name: "Pizzaria Itália",
                imageURL: URL(
                    string: "https://picsum.photos/120/120?1"
                ),
                rating: 4.8,
                deliveryTime: 30,
                deliveryFee: Decimal(string: "5.99")!
            ),
            Restaurant(
                id: UUID(),
                name: "Burger House",
                imageURL: URL(
                    string: "https://picsum.photos/120/120?2"
                ),
                rating: 4.5,
                deliveryTime: 20,
                deliveryFee: Decimal(string: "3.99")!
            )
        ]
    }
}

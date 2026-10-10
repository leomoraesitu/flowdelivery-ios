import Foundation

nonisolated struct FakeRestaurantRepository: RestaurantRepository {
    private let restaurants: [Restaurant]

    init(
        restaurants: [Restaurant] = FakeRestaurantRepository.defaultRestaurants
    ) {
        self.restaurants = restaurants
    }

    func fetchRestaurants() async throws -> [Restaurant] {
        restaurants
    }

    private static let defaultRestaurants: [Restaurant] = [
        Restaurant(
            id: UUID(),
            name: "Pizzaria Itália",
            imageURL: URL(
                string: "https://picsum.photos/120/120?1"
            ),
            rating: 4.8,
            deliveryTime: 30,
            deliveryFee: Decimal(string: "5.99")!,
            menu: []
        ),
        Restaurant(
            id: UUID(),
            name: "Burger House",
            imageURL: URL(
                string: "https://picsum.photos/120/120?2"
            ),
            rating: 4.5,
            deliveryTime: 20,
            deliveryFee: Decimal(string: "3.99")!,
            menu: []
        )
    ]
}

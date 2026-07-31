import Foundation

struct FakeRestaurantRepository: RestaurantRepository {
    func fetchRestaurants() -> [Restaurant] {
        [
            Restaurant(
                id: UUID(),
                name: "Pizzaria Itália"
            ),
            Restaurant(
                id: UUID(),
                name: "Burger House"
            )
        ]
    }
}

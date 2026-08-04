import Foundation

protocol RestaurantDetailsRepository {
    func fetchRestaurant(
        id: UUID
    ) async throws -> Restaurant
}

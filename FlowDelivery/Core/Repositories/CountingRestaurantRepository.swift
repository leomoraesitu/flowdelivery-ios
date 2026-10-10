final class CountingRestaurantRepository: RestaurantRepository {
    private(set) var callCount = 0

    func fetchRestaurants() async throws -> [Restaurant] {
        callCount += 1
        return []
    }
}

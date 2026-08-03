struct EmptyRestaurantRepository: RestaurantRepository {
    func fetchRestaurants() async throws -> [Restaurant] {
        []
    }
}

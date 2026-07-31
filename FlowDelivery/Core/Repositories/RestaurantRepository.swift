protocol RestaurantRepository {
    func fetchRestaurants() async throws -> [Restaurant]
}

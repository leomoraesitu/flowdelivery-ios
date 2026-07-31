protocol RestaurantRepository {
    func fetchRestaurants() async -> [Restaurant]
}

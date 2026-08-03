struct FailingRestaurantRepository: RestaurantRepository {
    struct Failure: Error {}

    func fetchRestaurants() async throws -> [Restaurant] {
        throw Failure()
    }
}

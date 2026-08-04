import Foundation
import Observation

@Observable
final class RestaurantDetailsViewModel {
    let restaurantID: UUID
    private let repository: RestaurantDetailsRepository

    init(
        restaurantID: UUID,
        repository: RestaurantDetailsRepository
    ) {
        self.restaurantID = restaurantID
        self.repository = repository
    }
}

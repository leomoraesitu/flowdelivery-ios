import Foundation
import Observation

@Observable
final class RestaurantDetailsViewModel {
    let restaurantID: UUID

    init(
        restaurantID: UUID
    ) {
        self.restaurantID = restaurantID
    }
}

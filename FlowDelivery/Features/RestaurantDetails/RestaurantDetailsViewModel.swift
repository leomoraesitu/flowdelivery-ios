import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class RestaurantDetailsViewModel {
    private(set) var state: RestaurantDetailsState = .loading

    let restaurantID: UUID

    private let repository: RestaurantDetailsRepository

    enum RestaurantDetailsState: Equatable {
        case loading
        case loaded(Restaurant)
        case error(RestaurantDetailsError)
    }

    enum RestaurantDetailsError: Equatable {
        case loadFailed
    }

    init(
        restaurantID: UUID,
        repository: RestaurantDetailsRepository
    ) {
        self.restaurantID = restaurantID
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            let restaurant = try await repository.fetchRestaurant(
                id: restaurantID
            )

            state = .loaded(restaurant)
        } catch {
            state = .error(.loadFailed)
        }
    }
}

extension RestaurantDetailsViewModel.RestaurantDetailsError {
    var message: LocalizedStringKey {
        switch self {
        case .loadFailed:
            "Não foi possível carregar os dados do restaurante."
        }
    }
}

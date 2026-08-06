import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class RestaurantDetailsViewModel {
    private(set) var state: RestaurantDetailsState = .loading

    let restaurantID: UUID

    private let repository: RestaurantDetailsRepository
    private let cartStore: CartStore

    enum RestaurantDetailsState: Equatable {
        case loading
        case loaded(
            RestaurantDetailsContent
        )
        case error(RestaurantDetailsError)
    }

    enum RestaurantDetailsError: Equatable {
        case loadFailed
    }

    init(
        restaurantID: UUID,
        repository: RestaurantDetailsRepository,
        cartStore: CartStore
    ) {
        self.restaurantID = restaurantID
        self.repository = repository
        self.cartStore = cartStore
    }

    func load() async {
        state = .loading

        do {
            let restaurant = try await repository.fetchRestaurant(
                id: restaurantID
            )

            state = .loaded(
                RestaurantDetailsContent(
                    restaurant: restaurant
                )
            )
        } catch {
            state = .error(.loadFailed)
        }
    }

    func addToCart(
        item: MenuItemContent
    ) {
        guard case let .loaded(content) = state,
              let menuItem = content.menuItem(id: item.id)
        else {
            return
        }
        cartStore.add(menuItem)
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

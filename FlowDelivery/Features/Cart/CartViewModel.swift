import Foundation
import Observation

@MainActor
@Observable
final class CartViewModel {
    private let cartStore: CartStore

    enum CartState: Equatable {
        case empty
        case loaded(CartContent)
    }

    init(
        cartStore: CartStore
    ) {
        self.cartStore = cartStore
    }

    var state: CartState {
        let items = cartStore.items

        guard !items.isEmpty else {
            return .empty
        }

        return .loaded(
            CartContent(
                cartItems: items,
                total: cartStore.total
            )
        )
    }

    func incrementQuantity(
        itemID: UUID
    ) {
        cartStore.incrementQuantity(
            itemID: itemID
        )
    }

    func decrementQuantity(
        itemID: UUID
    ) {
        cartStore.decrementQuantity(
            itemID: itemID
        )
    }

    func removeItem(
        itemID: UUID
    ) {
        cartStore.remove(
            itemID: itemID
        )
    }

    func clearCart() {
        cartStore.clear()
    }
}

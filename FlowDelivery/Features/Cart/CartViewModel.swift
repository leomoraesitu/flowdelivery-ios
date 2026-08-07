import Observation

@MainActor
@Observable
final class CartViewModel {
    private let cartStore: CartStore

    enum CartState: Equatable {
        case empty
        case loaded([CartItemContent])
    }

    init(
        cartStore: CartStore
    ) {
        self.cartStore = cartStore
    }

    var state: CartState {
        let items = cartStore.items.map {
            CartItemContent(
                cartItem: $0
            )
        }

        guard !items.isEmpty else {
            return .empty
        }

        return .loaded(items)
    }
}

import Observation

@MainActor
@Observable
final class CheckoutViewModel {
    private let cartStore: CartStore

    var deliveryAddress = ""
    var paymentMethod: PaymentMethod?

    enum CheckoutState: Equatable {
        case empty
        case loaded(CheckoutContent)
    }

    init(
        cartStore: CartStore
    ) {
        self.cartStore = cartStore
    }

    var state: CheckoutState {
        guard cartStore.itemCount > 0 else {
            return .empty
        }

        return .loaded(
            CheckoutContent(
                itemCount: cartStore.itemCount,
                total: cartStore.total
            )
        )
    }
}

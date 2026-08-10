import Foundation
import Observation

@MainActor
@Observable
final class CheckoutViewModel {
    private let cartStore: CartStore

    var deliveryAddress = ""
    var paymentMethod: PaymentMethod?

    var canConfirmOrder: Bool {
        let normalizedAddress = deliveryAddress.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return !normalizedAddress.isEmpty &&
            paymentMethod != nil &&
            cartStore.itemCount > 0
    }

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

    func confirmOrder() -> Bool {
        guard canConfirmOrder else {
            return false
        }

        cartStore.clear()

        deliveryAddress = ""
        paymentMethod = nil

        return true
    }
}

@testable import FlowDelivery
import Foundation
import Testing

struct CheckoutViewModelTests {
    @Test("Rejects incomplete checkout confirmation")
    @MainActor
    func confirmOrderRejectsIncompleteCheckout() {
        let cartStore = makeCartStore()

        let sut = CheckoutViewModel(
            cartStore: cartStore
        )

        sut.deliveryAddress =
            "Avenida Paulista, 1000, Bela Vista"

        let didConfirm = sut.confirmOrder()

        #expect(!didConfirm)
        #expect(cartStore.itemCount == 1)
        #expect(
            sut.deliveryAddress ==
                "Avenida Paulista, 1000, Bela Vista"
        )
        #expect(sut.paymentMethod == nil)
    }

    @Test("Clears checkout after a valid confirmation")
    @MainActor
    func confirmOrderClearsValidCheckout() {
        let cartStore = makeCartStore()

        let sut = CheckoutViewModel(
            cartStore: cartStore
        )

        sut.deliveryAddress =
            "Avenida Paulista, 1000, Bela Vista"

        sut.paymentMethod = .pix

        let didConfirm = sut.confirmOrder()

        #expect(didConfirm)
        #expect(cartStore.items.isEmpty)
        #expect(sut.deliveryAddress.isEmpty)
        #expect(sut.paymentMethod == nil)
        #expect(!sut.canConfirmOrder)
    }

    @MainActor
    private func makeCartStore() -> CartStore {
        let cartStore = CartStore()

        let menuItem = MenuItem(
            id: UUID(),
            name: "Pizza Margherita",
            description: "Molho de tomate, mussarela e manjericão.",
            price: Decimal(string: "49.90") ?? .zero,
            imageURL: nil
        )

        cartStore.add(menuItem)

        return cartStore
    }
}

@testable import FlowDelivery
import Foundation
import Testing

struct CheckoutViewModelTests {
    @Test("Rejects incomplete checkout confirmation")
    @MainActor
    func confirmOrderRejectsIncompleteCheckout() async {
        let cartStore = makeCartStore()
        let orderRepository = FakeOrderRepository()

        let sut = CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: orderRepository
        )

        sut.deliveryAddress =
            "Avenida Paulista, 1000, Bela Vista"

        let didConfirm = await sut.confirmOrder()

        #expect(!didConfirm)
        #expect(orderRepository.orders.isEmpty)
        #expect(cartStore.itemCount == 1)
        #expect(
            sut.deliveryAddress ==
                "Avenida Paulista, 1000, Bela Vista"
        )
        #expect(sut.paymentMethod == nil)
    }

    @Test("Creates order and clears checkout after valid confirmation")
    @MainActor
    func confirmOrderCreatesOrderAndClearsCheckout() async throws {
        let cartStore = makeCartStore()
        let expectedItems = cartStore.items
        let orderRepository = FakeOrderRepository()

        let sut = CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: orderRepository
        )

        sut.deliveryAddress =
            "Avenida Paulista, 1000, Bela Vista"

        sut.paymentMethod = .pix

        let didConfirm = await sut.confirmOrder()

        let createdOrder = try #require(
            orderRepository.orders.first
        )

        #expect(didConfirm)
        #expect(orderRepository.orders.count == 1)
        #expect(createdOrder.items == expectedItems)
        #expect(
            createdOrder.deliveryAddress ==
                "Avenida Paulista, 1000, Bela Vista"
        )
        #expect(createdOrder.paymentMethod == .pix)
        #expect(cartStore.items.isEmpty)
        #expect(sut.deliveryAddress.isEmpty)
        #expect(sut.paymentMethod == nil)
        #expect(!sut.canConfirmOrder)
    }

    @Test("Preserves checkout after an order creation failure")
    @MainActor
    func confirmOrderPreservesCheckoutAfterCreationFailure() async {
        let cartStore = makeCartStore()
        let expectedItems = cartStore.items

        let sut = CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: FailingOrderRepository()
        )

        sut.deliveryAddress =
            "Avenida Paulista, 1000, Bela Vista"

        sut.paymentMethod = .pix

        let didConfirm = await sut.confirmOrder()

        #expect(!didConfirm)
        #expect(cartStore.items == expectedItems)
        #expect(
            sut.deliveryAddress ==
                "Avenida Paulista, 1000, Bela Vista"
        )
        #expect(sut.paymentMethod == .pix)
        #expect(sut.canConfirmOrder)
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

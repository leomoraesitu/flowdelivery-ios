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
        #expect(sut.orderCreationError == nil)
        #expect(!sut.isSubmitting)
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
        #expect(sut.orderCreationError == nil)
        #expect(!sut.isSubmitting)
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
        #expect(sut.orderCreationError == .failed)
        #expect(sut.isOrderCreationErrorPresented)
        #expect(cartStore.items == expectedItems)
        #expect(
            sut.deliveryAddress ==
                "Avenida Paulista, 1000, Bela Vista"
        )
        #expect(sut.paymentMethod == .pix)
        #expect(sut.canConfirmOrder)

        sut.isOrderCreationErrorPresented = false

        #expect(sut.orderCreationError == nil)
        #expect(!sut.isOrderCreationErrorPresented)
        #expect(!sut.isSubmitting)
    }

    @Test("Prevents duplicate confirmation while submitting")
    @MainActor
    func confirmOrderPreventsDuplicateSubmission() async {
        let cartStore = makeCartStore()
        let orderRepository = SuspendingOrderRepository()

        let sut = CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: orderRepository
        )

        sut.deliveryAddress =
            "Avenida Paulista, 1000, Bela Vista"

        sut.paymentMethod = .pix

        let firstConfirmation = Task {
            await sut.confirmOrder()
        }

        await orderRepository.waitUntilStarted()

        #expect(sut.isSubmitting)
        #expect(!sut.canConfirmOrder)
        #expect(cartStore.itemCount == 1)

        let duplicateConfirmation = await sut.confirmOrder()

        #expect(!duplicateConfirmation)
        #expect(orderRepository.orders.count == 1)

        orderRepository.complete()

        let didConfirm = await firstConfirmation.value

        #expect(didConfirm)
        #expect(!sut.isSubmitting)
        #expect(cartStore.items.isEmpty)
        #expect(orderRepository.orders.count == 1)
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

    @Test("Rejects checkout with whitespace-only delivery address")
    @MainActor
    func confirmOrderRejectsWhitespaceOnlyAddress() async {
        let cartStore = makeCartStore()
        let orderRepository = FakeOrderRepository()

        let sut = CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: orderRepository
        )

        sut.deliveryAddress = " \n\t "
        sut.paymentMethod = .pix

        let didConfirm = await sut.confirmOrder()

        #expect(!didConfirm)
        #expect(!sut.canConfirmOrder)
        #expect(orderRepository.orders.isEmpty)
        #expect(cartStore.itemCount == 1)
        #expect(sut.deliveryAddress == " \n\t ")
        #expect(sut.paymentMethod == .pix)
        #expect(sut.orderCreationError == nil)
        #expect(!sut.isSubmitting)
    }

    @Test("Trims delivery address before creating order")
    @MainActor
    func confirmOrderTrimsDeliveryAddressBeforeCreatingOrder() async throws {
        let cartStore = makeCartStore()
        let orderRepository = FakeOrderRepository()

        let sut = CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: orderRepository
        )

        sut.deliveryAddress =
            " \n Avenida Paulista, 1000 \t"
        sut.paymentMethod = .pix

        let didConfirm = await sut.confirmOrder()

        let createdOrder = try #require(
            orderRepository.orders.first
        )

        #expect(didConfirm)
        #expect(
            createdOrder.deliveryAddress ==
                "Avenida Paulista, 1000"
        )
        #expect(createdOrder.paymentMethod == .pix)
        #expect(cartStore.items.isEmpty)
    }

    @Test("Checkout becomes unavailable when cart is cleared")
    @MainActor
    func checkoutBecomesUnavailableWhenCartIsCleared() {
        let cartStore = makeCartStore()

        let sut = CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: FakeOrderRepository()
        )

        sut.deliveryAddress =
            "Avenida Paulista, 1000"
        sut.paymentMethod = .pix

        #expect(sut.state != .empty)
        #expect(sut.canConfirmOrder)

        cartStore.clear()

        #expect(sut.state == .empty)
        #expect(!sut.canConfirmOrder)
    }

    @Test(
        "Persists every selected payment method",
        arguments: PaymentMethod.allCases
    )
    @MainActor
    func confirmOrderPersistsSelectedPaymentMethod(
        paymentMethod: PaymentMethod
    ) async throws {
        let cartStore = makeCartStore()
        let orderRepository = FakeOrderRepository()

        let sut = CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: orderRepository
        )

        sut.deliveryAddress =
            "Avenida Paulista, 1000"
        sut.paymentMethod = paymentMethod

        let didConfirm = await sut.confirmOrder()

        let createdOrder = try #require(
            orderRepository.orders.first
        )

        #expect(didConfirm)
        #expect(orderRepository.orders.count == 1)
        #expect(createdOrder.paymentMethod == paymentMethod)
        #expect(cartStore.items.isEmpty)
    }
}

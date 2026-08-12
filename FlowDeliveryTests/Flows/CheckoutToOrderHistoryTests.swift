@testable import FlowDelivery
import Foundation
import Testing

struct CheckoutToOrderHistoryTests {
    @Test("Confirmed order appears in order history")
    @MainActor
    func confirmedOrderAppearsInHistory() async throws {
        let cartStore = CartStore()
        let repository = FakeOrderRepository()

        let menuItem = MenuItem(
            id: UUID(),
            name: "Pizza Margherita",
            description: "Molho de tomate e mussarela.",
            price: Decimal(string: "49.90") ?? .zero,
            imageURL: nil
        )

        cartStore.add(menuItem)

        let checkoutViewModel = CheckoutViewModel(
            cartStore: cartStore,
            orderRepository: repository
        )

        checkoutViewModel.deliveryAddress =
            "Avenida Paulista, 1000"

        checkoutViewModel.paymentMethod = .pix

        let didConfirm = await checkoutViewModel.confirmOrder()

        #expect(didConfirm)
        #expect(repository.orders.count == 1)
        #expect(cartStore.items.isEmpty)

        let historyViewModel = OrderHistoryViewModel(
            repository: repository
        )

        await historyViewModel.load()

        guard case let .loaded(entries) = historyViewModel.state else {
            Issue.record("Expected loaded order history")
            return
        }

        let entry = try #require(entries.first)

        #expect(entry.id == repository.orders[0].id)
        #expect(entry.itemCount == "1 item")
        #expect(
            entry.total ==
                repository.orders[0].total.formatted(
                    .currency(code: "BRL")
                )
        )
    }
}

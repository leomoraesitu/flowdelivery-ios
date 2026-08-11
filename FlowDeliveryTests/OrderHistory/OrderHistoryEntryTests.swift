@testable import FlowDelivery
import Foundation
import Testing

struct OrderHistoryEntryTests {
    @Test("Maps order to presentation values")
    @MainActor
    func mapsOrderToPresentationValues() {
        let order = makeOrder(
            quantity: 2
        )

        let sut = OrderHistoryEntry(
            order: order
        )

        #expect(sut.id == order.id)

        #expect(
            sut.date ==
                order.createdAt.formatted(
                    date: .abbreviated,
                    time: .shortened
                )
        )

        #expect(sut.itemCount == "2 itens")

        #expect(
            sut.total ==
                order.total.formatted(
                    .currency(code: "BRL")
                )
        )
    }

    @Test("Formats singular item count")
    @MainActor
    func formatsSingularItemCount() {
        let order = makeOrder(
            quantity: 1
        )

        let sut = OrderHistoryEntry(
            order: order
        )

        #expect(sut.itemCount == "1 item")
    }

    private func makeOrder(
        quantity: Int
    ) -> Order {
        let menuItem = MenuItem(
            id: UUID(),
            name: "Pizza Margherita",
            description:
            "Molho de tomate, mussarela e manjericão.",
            price: Decimal(string: "49.90") ?? .zero,
            imageURL: nil
        )

        return Order(
            id: UUID(),
            items: [
                CartItem(
                    menuItem: menuItem,
                    quantity: quantity
                )
            ],
            deliveryAddress:
            "Avenida Paulista, 1000, Bela Vista",
            paymentMethod: .pix,
            createdAt: Date(
                timeIntervalSince1970: 1_700_000_000
            )
        )
    }
}

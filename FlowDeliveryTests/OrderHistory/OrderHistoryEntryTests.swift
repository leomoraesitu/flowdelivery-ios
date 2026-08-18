@testable import FlowDelivery
import Foundation
import Testing

struct OrderHistoryEntryTests {
    @Test("Maps order to presentation values")
    @MainActor
    func mapsOrderToPresentationValues() {
        let order = makeOrder(
            quantities: [2]
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
            quantities: [1]
        )

        let sut = OrderHistoryEntry(
            order: order
        )

        #expect(sut.itemCount == "1 item")
    }

    private func makeOrder(
        quantities: [Int]
    ) -> Order {
        let items = quantities.enumerated().map { index, quantity in
            let menuItem = MenuItem(
                id: UUID(),
                name: "Item \(index + 1)",
                description: "Descrição do item.",
                price: Decimal(string: "10.00") ?? .zero,
                imageURL: nil
            )

            return CartItem(
                menuItem: menuItem,
                quantity: quantity
            )
        }

        return Order(
            id: UUID(),
            items: items,
            deliveryAddress:
            "Avenida Paulista, 1000, Bela Vista",
            paymentMethod: .pix,
            createdAt: Date(
                timeIntervalSince1970: 1_700_000_000
            )
        )
    }

    @Test("Sums quantities across different order items")
    @MainActor
    func sumsQuantitiesAcrossDifferentOrderItems() {
        let order = makeOrder(
            quantities: [
                1,
                2
            ]
        )

        let sut = OrderHistoryEntry(
            order: order
        )

        #expect(sut.itemCount == "3 itens")
    }
}

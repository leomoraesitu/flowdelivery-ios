@testable import FlowDelivery
import Foundation
import Testing

struct OrderDetailsContentTests {
    @Test("Maps order to presentation values")
    @MainActor
    func mapsOrderToPresentationValues() {
        let menuItem = MenuItem(
            id: UUID(),
            name: "Pizza Margherita",
            description:
            "Molho de tomate, mussarela e manjericão.",
            price: Decimal(string: "49.90") ?? .zero,
            imageURL: nil
        )

        let cartItem = CartItem(
            menuItem: menuItem,
            quantity: 2
        )

        let order = Order(
            id: UUID(),
            items: [cartItem],
            deliveryAddress:
            "Avenida Paulista, 1000, Bela Vista",
            paymentMethod: .pix,
            createdAt: Date(
                timeIntervalSince1970: 1_700_000_000
            )
        )

        let sut = OrderDetailsContent(
            order: order
        )

        let expectedDate = order.createdAt.formatted(
            date: .abbreviated,
            time: .shortened
        )

        let expectedUnitPrice = menuItem.price.formatted(
            .currency(code: "BRL")
        )

        let expectedSubtotal = cartItem.subtotal.formatted(
            .currency(code: "BRL")
        )

        let expectedTotal = order.total.formatted(
            .currency(code: "BRL")
        )

        #expect(sut.date == expectedDate)
        #expect(
            sut.deliveryAddress ==
                order.deliveryAddress
        )
        #expect(sut.paymentMethod == "Pix")
        #expect(sut.total == expectedTotal)

        #expect(
            sut.items == [
                OrderDetailsItemContent(
                    id: cartItem.id,
                    title: menuItem.name,
                    quantityAndUnitPrice:
                    "2 × \(expectedUnitPrice)",
                    subtotal: expectedSubtotal
                )
            ]
        )
    }
}

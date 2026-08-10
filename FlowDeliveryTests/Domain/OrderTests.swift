@testable import FlowDelivery
import Foundation
import Testing

struct OrderTests {
    @Test("Calculates the total from its items")
    func calculatesTotalFromItems() {
        let firstItem = MenuItem(
            id: UUID(),
            name: "Pizza",
            description: "Pizza de mussarela",
            price: Decimal(string: "10.00") ?? .zero,
            imageURL: nil
        )

        let secondItem = MenuItem(
            id: UUID(),
            name: "Refrigerante",
            description: "Lata de refrigerante",
            price: Decimal(string: "5.50") ?? .zero,
            imageURL: nil
        )

        let order = Order(
            id: UUID(),
            items: [
                CartItem(
                    menuItem: firstItem,
                    quantity: 2
                ),
                CartItem(
                    menuItem: secondItem,
                    quantity: 1
                )
            ],
            deliveryAddress: "Avenida Paulista, 1000",
            paymentMethod: .pix,
            createdAt: Date(
                timeIntervalSince1970: .zero
            )
        )

        let expectedTotal =
            Decimal(string: "25.50") ?? .zero

        #expect(order.total == expectedTotal)
    }
}

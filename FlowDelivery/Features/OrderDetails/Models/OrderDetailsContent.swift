import Foundation

struct OrderDetailsContent: Equatable {
    let date: String
    let deliveryAddress: String
    let paymentMethod: String
    let items: [OrderDetailsItemContent]
    let total: String
}

struct OrderDetailsItemContent: Identifiable, Equatable {
    let id: UUID
    let title: String
    let quantityAndUnitPrice: String
    let subtotal: String
}

extension OrderDetailsContent {
    init(
        order: Order
    ) {
        date = order.createdAt.formatted(
            date: .abbreviated,
            time: .shortened
        )

        deliveryAddress = order.deliveryAddress
        paymentMethod = order.paymentMethod.title

        items = order.items.map { cartItem in
            OrderDetailsItemContent(
                cartItem: cartItem
            )
        }
        total = order.total.formatted(
            .currency(code: "BRL")
        )
    }
}

extension OrderDetailsItemContent {
    init(
        cartItem: CartItem
    ) {
        id = cartItem.id
        title = cartItem.menuItem.name

        let unitPrice = cartItem.menuItem.price.formatted(
            .currency(code: "BRL")
        )

        quantityAndUnitPrice =
            "\(cartItem.quantity) × \(unitPrice)"

        subtotal = cartItem.subtotal.formatted(
            .currency(code: "BRL")
        )
    }
}

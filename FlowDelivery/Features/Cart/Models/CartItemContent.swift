import Foundation

struct CartItemContent: Identifiable, Equatable {
    let id: UUID
    let title: String
    let unitPrice: String
    let quantity: Int
    let subtotal: String
}

extension CartItemContent {
    init(
        cartItem: CartItem
    ) {
        id = cartItem.id
        title = cartItem.menuItem.name
        unitPrice = cartItem.menuItem.price.formatted(
            .currency(code: "BRL")
        )
        quantity = cartItem.quantity
        subtotal = cartItem.subtotal.formatted(
            .currency(code: "BRL")
        )
    }
}

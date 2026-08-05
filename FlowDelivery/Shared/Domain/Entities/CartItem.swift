import Foundation

struct CartItem: Identifiable, Equatable {
    let menuItem: MenuItem
    var quantity: Int

    var id: UUID {
        menuItem.id
    }

    var subtotal: Decimal {
        menuItem.price * Decimal(quantity)
    }
}

import Foundation

struct CartContent: Equatable {
    let items: [CartItemContent]
    let total: String
}

extension CartContent {
    init(
        cartItems: [CartItem],
        total: Decimal
    ) {
        items = cartItems.map {
            CartItemContent(
                cartItem: $0
            )
        }

        self.total = total.formatted(
            .currency(code: "BRL")
        )
    }
}

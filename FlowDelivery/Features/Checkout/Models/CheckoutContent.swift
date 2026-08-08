import Foundation

struct CheckoutContent: Equatable {
    let itemCount: String
    let total: String
}

extension CheckoutContent {
    init(
        itemCount: Int,
        total: Decimal
    ) {
        switch itemCount {
        case 1:
            self.itemCount = "1 item"

        default:
            self.itemCount = "\(itemCount) itens"
        }

        self.total = total.formatted(
            .currency(code: "BRL")
        )
    }
}

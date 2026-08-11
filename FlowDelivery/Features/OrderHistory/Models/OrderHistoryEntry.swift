import Foundation

struct OrderHistoryEntry: Identifiable, Equatable {
    let id: UUID
    let date: String
    let itemCount: String
    let total: String
}

extension OrderHistoryEntry {
    init(
        order: Order
    ) {
        id = order.id

        date = order.createdAt.formatted(
            date: .abbreviated,
            time: .shortened
        )

        let itemCount = order.items.reduce(0) { result, item in
            result + item.quantity
        }

        switch itemCount {
        case 1:
            self.itemCount = "1 item"

        default:
            self.itemCount = "\(itemCount) itens"
        }

        total = order.total.formatted(
            .currency(code: "BRL")
        )
    }
}

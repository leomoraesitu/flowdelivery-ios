import Foundation
import Observation

@MainActor
@Observable
final class CartStore {
    private(set) var items: [CartItem] = []

    var itemCount: Int {
        items.reduce(0) { result, item in
            result + item.quantity
        }
    }

    var total: Decimal {
        items.reduce(Decimal.zero) { result, item in
            result + item.subtotal
        }
    }

    func add(_ menuItem: MenuItem) {
        guard let index = items.firstIndex(
            where: { $0.menuItem.id == menuItem.id }
        ) else {
            items.append(
                CartItem(
                    menuItem: menuItem,
                    quantity: 1
                )
            )
            return
        }

        items[index].quantity += 1
    }
}

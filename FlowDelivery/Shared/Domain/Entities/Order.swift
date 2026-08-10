import Foundation

struct Order: Identifiable, Equatable {
    let id: UUID
    let items: [CartItem]
    let deliveryAddress: String
    let paymentMethod: PaymentMethod
    let createdAt: Date

    var total: Decimal {
        items.reduce(.zero) { result, item in
            result + item.subtotal
        }
    }
}

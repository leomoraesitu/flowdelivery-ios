import Foundation

struct Restaurant: Identifiable, Equatable {
    let id: UUID
    let name: String
    let imageURL: URL?
    let rating: Double
    let deliveryTime: Int
    let deliveryFee: Decimal
}

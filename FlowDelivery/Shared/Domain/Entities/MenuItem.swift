import Foundation

struct MenuItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let price: Decimal
    let imageURL: URL?
}

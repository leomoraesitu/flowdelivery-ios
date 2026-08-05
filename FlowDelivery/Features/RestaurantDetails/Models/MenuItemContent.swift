import Foundation

struct MenuItemContent: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let price: String
    let imageURL: URL?
}

extension MenuItemContent {
    init(
        menuItem: MenuItem
    ) {
        id = menuItem.id
        title = menuItem.name
        description = menuItem.description
        price = menuItem.price.formatted(
            .currency(code: "BRL")
        )
        imageURL = menuItem.imageURL
    }
}

import SwiftUI

struct RestaurantMenuView: View {
    let menu: [MenuItemContent]
    let onAdd: (MenuItemContent) -> Void

    var body: some View {
        LazyVStack(
            alignment: .leading,
            spacing: AppSpacing.medium
        ) {
            ForEach(menu) { item in
                MenuItemRowView(
                    content: item,
                    onAdd: {
                        onAdd(item)
                    }
                )
            }
        }
    }
}

#Preview {
    RestaurantMenuView(
        menu: [
            MenuItemContent(
                menuItem: MenuItem(
                    id: UUID(),
                    name: "Pizza Margherita",
                    description: "Molho de tomate, mussarela e manjericão.",
                    price: Decimal(string: "49.90")!,
                    imageURL: nil
                )
            ),
            MenuItemContent(
                menuItem: MenuItem(
                    id: UUID(),
                    name: "Pizza Calabresa",
                    description: "Calabresa, cebola e mussarela.",
                    price: Decimal(string: "54.90")!,
                    imageURL: nil
                )
            )
        ],
        onAdd: { _ in }
    )
}

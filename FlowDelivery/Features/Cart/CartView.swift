import SwiftUI

struct CartView: View {
    let viewModel: CartViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .empty:
                ContentUnavailableView(
                    "Seu carrinho está vazio",
                    systemImage: "cart",
                    description: Text(
                        "Adicione itens de um restaurante para começar."
                    )
                )

            case let .loaded(items):
                List(items) { item in
                    CartItemRowView(
                        content: item
                    )
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Carrinho")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Empty") {
    NavigationStack {
        CartView(
            viewModel: CartViewModel(
                cartStore: CartStore()
            )
        )
    }
}

#Preview("With items") {
    let cartStore = CartStore()

    let menuItem = MenuItem(
        id: UUID(),
        name: "Pizza Margherita",
        description: "Molho de tomate, mussarela e manjericão.",
        price: Decimal(string: "49.90") ?? .zero,
        imageURL: nil
    )

    cartStore.add(menuItem)
    cartStore.add(menuItem)

    return NavigationStack {
        CartView(
            viewModel: CartViewModel(
                cartStore: cartStore
            )
        )
    }
}

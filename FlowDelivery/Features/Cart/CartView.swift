import SwiftUI

struct CartView: View {
    @State
    private var isClearCartConfirmationPresented = false

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

            case let .loaded(content):
                List(content.items) { item in
                    CartItemRowView(
                        content: item,
                        onDecrement: {
                            viewModel.decrementQuantity(
                                itemID: item.id
                            )
                        },
                        onIncrement: {
                            viewModel.incrementQuantity(
                                itemID: item.id
                            )
                        }
                    )
                    .swipeActions(
                        edge: .trailing,
                        allowsFullSwipe: false
                    ) {
                        Button(
                            role: .destructive
                        ) {
                            viewModel.removeItem(
                                itemID: item.id
                            )
                        } label: {
                            Label(
                                "Remover",
                                systemImage: "trash"
                            )
                        }
                    }
                }
                .listStyle(.plain)
                .safeAreaInset(
                    edge: .bottom,
                    spacing: .zero
                ) {
                    CartSummaryView(
                        total: content.total
                    ) {
                        NavigationLink(
                            value: AppRoute.checkout
                        ) {
                            Text("Finalizar pedido")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
            }
        }
        .navigationTitle("Carrinho")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(
                placement: .topBarTrailing
            ) {
                if case .loaded = viewModel.state {
                    Button(
                        role: .destructive
                    ) {
                        isClearCartConfirmationPresented = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Limpar carrinho")
                }
            }
        }
        .confirmationDialog(
            "Limpar carrinho?",
            isPresented: $isClearCartConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(
                "Limpar carrinho",
                role: .destructive
            ) {
                viewModel.clearCart()
            }

            Button(
                "Cancelar",
                role: .cancel
            ) {}
        } message: {
            Text(
                "Todos os itens e suas quantidades serão removidos."
            )
        }
    }
}

#Preview("Empty") {
    let cartStore = CartStore()

    NavigationStack {
        CartView(
            viewModel: CartViewModel(
                cartStore: cartStore
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

import SwiftUI

struct CheckoutView: View {
    let viewModel: CheckoutViewModel
    var body: some View {
        Group {
            switch viewModel.state {
            case .empty:
                ContentUnavailableView(
                    "Checkout indisponível",
                    systemImage: "cart",
                    description: Text(
                        "Adicione itens ao carrinho para continuar."
                    )
                )

            case let .loaded(content):
                List {
                    Section(
                        "Resumo do pedido"
                    ) {
                        LabeledContent(
                            "Itens",
                            value: content.itemCount
                        )

                        LabeledContent {
                            Text(content.total)
                                .font(AppTypography.bodyBold)
                                .monospacedDigit()
                        } label: {
                            Text("Total")
                                .font(AppTypography.bodyBold)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Finalizar pedido")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Empty") {
    NavigationStack {
        CheckoutView(
            viewModel: CheckoutViewModel(
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
        CheckoutView(
            viewModel: CheckoutViewModel(
                cartStore: cartStore
            )
        )
    }
}

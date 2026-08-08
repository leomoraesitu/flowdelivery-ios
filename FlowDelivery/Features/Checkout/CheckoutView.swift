import SwiftUI

struct CheckoutView: View {
    @Bindable
    var viewModel: CheckoutViewModel
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

                    Section(
                        "Endereço de entrega"
                    ) {
                        TextField(
                            "Rua, número e complemento",
                            text: $viewModel.deliveryAddress,
                            axis: .vertical
                        )
                        .textContentType(.fullStreetAddress)
                        .textInputAutocapitalization(.words)
                        .lineLimit(2 ... 3)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollDismissesKeyboard(.interactively)
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

    let checkoutViewModel = CheckoutViewModel(
        cartStore: cartStore
    )

    checkoutViewModel.deliveryAddress =
        "Avenida Paulista, 1000, Bela Vista"

    return NavigationStack {
        CheckoutView(
            viewModel: checkoutViewModel
        )
    }
}

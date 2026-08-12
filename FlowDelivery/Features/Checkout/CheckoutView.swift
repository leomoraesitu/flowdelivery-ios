import SwiftUI

struct CheckoutView: View {
    @State
    private var isOrderConfirmationPresented = false

    @State
    private var isOrderCompleted = false

    @Bindable
    var viewModel: CheckoutViewModel
    var body: some View {
        Group {
            if isOrderCompleted {
                OrderSuccessView {
                    NavigationLink(
                        value: AppRoute.orderHistory
                    ) {
                        Text("Ver meus pedidos")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            } else {
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
                        Section(
                            "Pagamento"
                        ) {
                            Picker(
                                "Forma de pagamento",
                                selection: $viewModel.paymentMethod
                            ) {
                                Text("Selecione")
                                    .tag(PaymentMethod?.none)

                                ForEach(PaymentMethod.allCases) { paymentMethod in
                                    Label(
                                        paymentMethod.title,
                                        systemImage: paymentMethod.systemImage
                                    )
                                    .tag(paymentMethod)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollDismissesKeyboard(.interactively)
                    .disabled(
                        viewModel.isSubmitting
                    )
                    .safeAreaInset(
                        edge: .bottom,
                        spacing: .zero
                    ) {
                        VStack(spacing: .zero) {
                            Button {
                                isOrderConfirmationPresented = true
                            } label: {
                                if viewModel.isSubmitting {
                                    ProgressView()
                                        .tint(AppColor.onPrimary)
                                        .accessibilityLabel(
                                            "Enviando pedido"
                                        )
                                } else {
                                    Text("Confirmar pedido")
                                }
                            }
                            .buttonStyle(
                                PrimaryButtonStyle()
                            )
                            .disabled(
                                !viewModel.canConfirmOrder
                            )
                        }
                        .padding(AppSpacing.large)
                        .frame(maxWidth: .infinity)
                        .background(.regularMaterial)
                        .overlay(
                            alignment: .top
                        ) {
                            Divider()
                        }
                    }
                }
            }
        }
        .navigationTitle("Finalizar pedido")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Confirmar pedido?",
            isPresented: $isOrderConfirmationPresented
        ) {
            Button(
                "Cancelar",
                role: .cancel
            ) {}

            Button(
                "Fazer pedido",
                role: .confirm
            ) {
                Task {
                    guard await viewModel.confirmOrder() else {
                        return
                    }

                    isOrderCompleted = true
                }
            }
        } message: {
            Text(
                "Confira o endereço e a forma de pagamento antes de continuar."
            )
        }
        .alert(
            "Não foi possível fazer o pedido",
            isPresented: $viewModel.isOrderCreationErrorPresented,
            presenting: viewModel.orderCreationError
        ) { _ in
            Button(
                "OK",
                role: .cancel
            ) {}
        } message: { error in
            Text(error.message)
        }
    }
}

#Preview("Empty") {
    NavigationStack {
        CheckoutView(
            viewModel: CheckoutViewModel(
                cartStore: CartStore(),
                orderRepository: FakeOrderRepository()
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
        cartStore: cartStore,
        orderRepository: FakeOrderRepository()
    )

    checkoutViewModel.deliveryAddress =
        "Avenida Paulista, 1000, Bela Vista"

    checkoutViewModel.paymentMethod = .pix

    return NavigationStack {
        CheckoutView(
            viewModel: checkoutViewModel
        )
    }
}

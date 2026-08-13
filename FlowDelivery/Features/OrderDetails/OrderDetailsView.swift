import SwiftUI

struct OrderDetailsView: View {
    @State
    private var viewModel: OrderDetailsViewModel

    init(
        viewModel: OrderDetailsViewModel
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
    }

    var body: some View {
        content
            .navigationTitle("Detalhes do pedido")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

        case let .loaded(content):
            orderDetails(
                content: content
            )

        case .notFound:
            ContentUnavailableView(
                "Pedido não encontrado",
                systemImage: "bag.badge.questionmark",
                description: Text(
                    "Não foi possível encontrar os detalhes deste pedido."
                )
            )

        case let .error(error):
            ContentUnavailableView {
                Label(
                    error.message,
                    systemImage: "wifi.exclamationmark"
                )
            } actions: {
                Button("Tentar novamente") {
                    Task {
                        await viewModel.load()
                    }
                }
            }
        }
    }

    private func orderDetails(
        content: OrderDetailsContent
    ) -> some View {
        List {
            Section("Pedido") {
                LabeledContent(
                    "Data",
                    value: content.date
                )

                LabeledContent(
                    "Pagamento",
                    value: content.paymentMethod
                )
                .accessibilityIdentifier("OrderDetails.PaymentMethod")
            }

            Section("Entrega") {
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.xSmall
                ) {
                    Text("Endereço")
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)

                    Text(content.deliveryAddress)
                        .font(AppTypography.body)
                }
            }

            Section("Itens") {
                ForEach(content.items) { item in
                    orderItemRow(
                        item: item
                    )
                }
            }

            Section {
                LabeledContent("Total") {
                    Text(content.total)
                        .font(AppTypography.bodyBold)
                        .monospacedDigit()
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func orderItemRow(
        item: OrderDetailsItemContent
    ) -> some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: AppSpacing.medium
        ) {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.xSmall
            ) {
                Text(item.title)
                    .font(AppTypography.headline)

                Text(item.quantityAndUnitPrice)
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(item.subtotal)
                .font(AppTypography.bodyBold)
                .monospacedDigit()
        }
        .accessibilityElement(
            children: .combine
        )
    }
}

extension OrderDetailsViewModel.OrderDetailsError {
    var message: LocalizedStringKey {
        switch self {
        case .loadFailed:
            "Não foi possível carregar os detalhes do pedido."
        }
    }
}

#Preview("Loaded") {
    let orderID = UUID()

    let menuItem = MenuItem(
        id: UUID(),
        name: "Pizza Margherita",
        description:
        "Molho de tomate, mussarela e manjericão.",
        price: Decimal(string: "49.90") ?? .zero,
        imageURL: nil
    )

    let order = Order(
        id: orderID,
        items: [
            CartItem(
                menuItem: menuItem,
                quantity: 2
            )
        ],
        deliveryAddress:
        "Avenida Paulista, 1000, Bela Vista",
        paymentMethod: .pix,
        createdAt: .now
    )

    return NavigationStack {
        OrderDetailsView(
            viewModel: OrderDetailsViewModel(
                orderID: orderID,
                repository: FakeOrderRepository(
                    orders: [order]
                )
            )
        )
    }
}

#Preview("Not found") {
    NavigationStack {
        OrderDetailsView(
            viewModel: OrderDetailsViewModel(
                orderID: UUID(),
                repository: FakeOrderRepository()
            )
        )
    }
}

#Preview("Error") {
    NavigationStack {
        OrderDetailsView(
            viewModel: OrderDetailsViewModel(
                orderID: UUID(),
                repository: FailingOrderRepository()
            )
        )
    }
}

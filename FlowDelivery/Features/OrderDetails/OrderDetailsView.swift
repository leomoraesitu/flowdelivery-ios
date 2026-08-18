import SwiftUI

struct OrderDetailsView: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

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
            orderSection(
                content: content
            )

            deliverySection(
                content: content
            )

            itemsSection(
                content: content
            )

            totalSection(
                content: content
            )
        }
        .listStyle(.insetGrouped)
    }

    private func orderSection(
        content: OrderDetailsContent
    ) -> some View {
        Section {
            LabeledContent(
                "Data",
                value: content.date
            )

            LabeledContent(
                "Pagamento",
                value: content.paymentMethod
            )
            .accessibilityIdentifier("OrderDetails.PaymentMethod")
        } header: {
            Text("Pedido")
                .foregroundStyle(.primary)
        }
        .headerProminence(.increased)
    }

    private func deliverySection(
        content: OrderDetailsContent
    ) -> some View {
        Section {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.xSmall
            ) {
                Text("Endereço")
                    .font(AppTypography.caption)
                    .foregroundStyle(.primary)

                Text(content.deliveryAddress)
                    .font(AppTypography.body)
                    .accessibilityIdentifier(
                        "OrderDetails.DeliveryAddress"
                    )
            }
        } header: {
            Text("Entrega")
                .foregroundStyle(.primary)
        }
        .headerProminence(.increased)
    }

    private func itemsSection(
        content: OrderDetailsContent
    ) -> some View {
        Section {
            ForEach(content.items) { item in
                orderItemRow(
                    item: item
                )
            }
        } header: {
            Text("Itens")
                .foregroundStyle(.primary)
        }
        .headerProminence(.increased)
    }

    private func totalSection(
        content: OrderDetailsContent
    ) -> some View {
        Section {
            LabeledContent("Total") {
                Text(content.total)
                    .font(AppTypography.bodyBold)
                    .monospacedDigit()
                    .accessibilityIdentifier(
                        "OrderDetails.Total"
                    )
            }
        }
    }

    @ViewBuilder
    private func orderItemRow(
        item: OrderDetailsItemContent
    ) -> some View {
        if dynamicTypeSize > .large {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.xSmall
            ) {
                itemInformation(
                    item: item
                )

                itemSubtotal(
                    item: item
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .trailing
                )
            }
        } else {
            HStack(
                alignment: .firstTextBaseline,
                spacing: AppSpacing.medium
            ) {
                itemInformation(
                    item: item
                )

                Spacer()

                itemSubtotal(
                    item: item
                )
            }
        }
    }

    private func itemInformation(
        item: OrderDetailsItemContent
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.xSmall
        ) {
            Text(item.title)
                .font(AppTypography.headline)

            Text(item.quantityAndUnitPrice)
                .font(AppTypography.caption)
                .foregroundStyle(.primary)
        }
    }

    private func itemSubtotal(
        item: OrderDetailsItemContent
    ) -> some View {
        Text(item.subtotal)
            .font(AppTypography.bodyBold)
            .monospacedDigit()
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

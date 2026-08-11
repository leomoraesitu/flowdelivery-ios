import SwiftUI

struct OrderHistoryView: View {
    @State
    private var viewModel: OrderHistoryViewModel

    let makeOrderDetailsViewModel:
        (UUID) -> OrderDetailsViewModel

    init(
        viewModel: OrderHistoryViewModel,
        makeOrderDetailsViewModel:
        @escaping (UUID) -> OrderDetailsViewModel
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
        self.makeOrderDetailsViewModel =
            makeOrderDetailsViewModel
    }

    var body: some View {
        content
            .navigationTitle("Meus pedidos")
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

        case let .loaded(entries):
            List(entries) { entry in
                NavigationLink {
                    OrderDetailsView(
                        viewModel: makeOrderDetailsViewModel(
                            entry.id
                        )
                    )
                } label: {
                    orderRow(
                        entry: entry
                    )
                }
                .accessibilityHint(
                    "Abre os detalhes do pedido"
                )
            }
            .listStyle(.plain)

        case .empty:
            ContentUnavailableView(
                "Nenhum pedido ainda",
                systemImage: "bag",
                description: Text(
                    "Seus pedidos aparecerão aqui depois da primeira compra."
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

    private func orderRow(
        entry: OrderHistoryEntry
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {
            Text(entry.date)
                .font(AppTypography.headline)

            HStack {
                Label(
                    entry.itemCount,
                    systemImage: "bag"
                )

                Spacer()

                Text(entry.total)
                    .font(AppTypography.bodyBold)
                    .monospacedDigit()
            }
            .font(AppTypography.caption)
            .foregroundStyle(.secondary)
        }
        .padding(
            .vertical,
            AppSpacing.xSmall
        )
        .accessibilityElement(
            children: .combine
        )
    }
}

extension OrderHistoryViewModel.OrderHistoryError {
    var message: LocalizedStringKey {
        switch self {
        case .loadFailed:
            "Não foi possível carregar seus pedidos."
        }
    }
}

#Preview("Empty") {
    let repository = FakeOrderRepository()

    NavigationStack {
        OrderHistoryView(
            viewModel: OrderHistoryViewModel(
                repository: repository
            ),
            makeOrderDetailsViewModel: { orderID in
                OrderDetailsViewModel(
                    orderID: orderID,
                    repository: repository
                )
            }
        )
    }
}

#Preview("Error") {
    let repository = FailingOrderRepository()

    NavigationStack {
        OrderHistoryView(
            viewModel: OrderHistoryViewModel(
                repository: repository
            ),
            makeOrderDetailsViewModel: { orderID in
                OrderDetailsViewModel(
                    orderID: orderID,
                    repository: repository
                )
            }
        )
    }
}

#Preview("With orders") {
    let menuItem = MenuItem(
        id: UUID(),
        name: "Pizza Margherita",
        description:
        "Molho de tomate, mussarela e manjericão.",
        price: Decimal(string: "49.90") ?? .zero,
        imageURL: nil
    )

    let order = Order(
        id: UUID(),
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

    let repository = FakeOrderRepository(
        orders: [order]
    )

    NavigationStack {
        OrderHistoryView(
            viewModel: OrderHistoryViewModel(
                repository: repository
            ),
            makeOrderDetailsViewModel: { orderID in
                OrderDetailsViewModel(
                    orderID: orderID,
                    repository: repository
                )
            }
        )
    }
}

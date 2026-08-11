import SwiftUI

struct OrderHistoryView: View {
    @State
    private var viewModel: OrderHistoryViewModel

    init(
        viewModel: OrderHistoryViewModel
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
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
                orderRow(
                    entry: entry
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
    NavigationStack {
        OrderHistoryView(
            viewModel: OrderHistoryViewModel(
                repository: FakeOrderRepository()
            )
        )
    }
}

#Preview("Error") {
    NavigationStack {
        OrderHistoryView(
            viewModel: OrderHistoryViewModel(
                repository: FailingOrderRepository()
            )
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

    return NavigationStack {
        OrderHistoryView(
            viewModel: OrderHistoryViewModel(
                repository: FakeOrderRepository(
                    orders: [order]
                )
            )
        )
    }
}

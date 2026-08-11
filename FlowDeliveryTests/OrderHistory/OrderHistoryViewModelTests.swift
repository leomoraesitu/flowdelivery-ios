@testable import FlowDelivery
import Foundation
import Testing

struct OrderHistoryViewModelTests {
    @Test("Starts in loading state")
    @MainActor
    func startsInLoadingState() {
        let sut = OrderHistoryViewModel(
            repository: FakeOrderRepository()
        )

        #expect(sut.state == .loading)
    }

    @Test("Displays empty state when no orders exist")
    @MainActor
    func loadDisplaysEmptyState() async {
        let sut = OrderHistoryViewModel(
            repository: FakeOrderRepository()
        )

        await sut.load()

        #expect(sut.state == .empty)
    }

    @Test("Displays fetched orders")
    @MainActor
    func loadDisplaysFetchedOrders() async throws {
        let repository = FakeOrderRepository()
        let order = makeOrder()

        try await repository.createOrder(order)

        let sut = OrderHistoryViewModel(
            repository: repository
        )

        let expectedEntry = OrderHistoryEntry(
            order: order
        )

        await sut.load()

        #expect(
            sut.state == .loaded([expectedEntry])
        )
    }

    @Test("Displays error state when loading fails")
    @MainActor
    func loadDisplaysErrorState() async {
        let sut = OrderHistoryViewModel(
            repository: FailingOrderRepository()
        )

        await sut.load()

        #expect(
            sut.state == .error(.loadFailed)
        )
    }

    private func makeOrder() -> Order {
        let menuItem = MenuItem(
            id: UUID(),
            name: "Pizza Margherita",
            description: "Molho de tomate, mussarela e manjericão.",
            price: Decimal(string: "49.90") ?? .zero,
            imageURL: nil
        )

        return Order(
            id: UUID(),
            items: [
                CartItem(
                    menuItem: menuItem,
                    quantity: 1
                )
            ],
            deliveryAddress:
            "Avenida Paulista, 1000, Bela Vista",
            paymentMethod: .pix,
            createdAt: .now
        )
    }
}

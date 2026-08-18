@testable import FlowDelivery
import Foundation
import Testing

struct OrderDetailsViewModelTests {
    @Test("Loads an existing order")
    @MainActor
    func loadExistingOrder() async {
        let order = makeOrder()
        let repository = FakeOrderRepository(
            orders: [order]
        )
        let sut = OrderDetailsViewModel(
            orderID: order.id,
            repository: repository
        )

        await sut.load()

        #expect(
            sut.state == .loaded(
                OrderDetailsContent(order: order)
            )
        )
    }

    @Test("Shows not found when order does not exist")
    @MainActor
    func loadMissingOrder() async {
        let repository = FakeOrderRepository()
        let sut = OrderDetailsViewModel(
            orderID: UUID(),
            repository: repository
        )

        await sut.load()

        #expect(sut.state == .notFound)
    }

    @Test("Starts in loading state")
    @MainActor
    func startsInLoadingState() {
        let sut = OrderDetailsViewModel(
            orderID: UUID(),
            repository: FakeOrderRepository()
        )

        #expect(sut.state == .loading)
    }

    @Test("Displays the fetched order")
    @MainActor
    func loadDisplaysFetchedOrder() async {
        let order = makeOrder()

        let sut = OrderDetailsViewModel(
            orderID: order.id,
            repository: FakeOrderRepository(
                orders: [order]
            )
        )

        let expectedContent = OrderDetailsContent(
            order: order
        )

        await sut.load()

        #expect(
            sut.state == .loaded(expectedContent)
        )
    }

    @Test("Displays not found state")
    @MainActor
    func loadDisplaysNotFoundState() async {
        let sut = OrderDetailsViewModel(
            orderID: UUID(),
            repository: FakeOrderRepository()
        )

        await sut.load()

        #expect(sut.state == .notFound)
    }

    @Test("Displays error state when loading fails")
    @MainActor
    func loadDisplaysErrorState() async {
        let sut = OrderDetailsViewModel(
            orderID: UUID(),
            repository: FailingOrderRepository()
        )

        await sut.load()

        #expect(
            sut.state == .error(.loadFailed)
        )
    }

    @Test("Loads order details after retrying a failed request")
    @MainActor
    func loadRecoversAfterFailure() async {
        let order = makeOrder()
        let repository = FailOnceFetchOrderRepository(
            order: order
        )

        let sut = OrderDetailsViewModel(
            orderID: order.id,
            repository: repository
        )

        await sut.load()

        #expect(sut.state == .error(.loadFailed))

        await sut.load()

        #expect(
            sut.state == .loaded(
                OrderDetailsContent(order: order)
            )
        )
    }

    private func makeOrder() -> Order {
        let menuItem = MenuItem(
            id: UUID(),
            name: "Pizza Margherita",
            description:
            "Molho de tomate, mussarela e manjericão.",
            price: Decimal(string: "49.90") ?? .zero,
            imageURL: nil
        )

        return Order(
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
    }
}

private final class FailOnceFetchOrderRepository: OrderRepository {
    private let order: Order
    private var shouldFail = true

    init(
        order: Order
    ) {
        self.order = order
    }

    func createOrder(
        _ order: Order
    ) async throws {
        _ = order
    }

    func fetchOrders() async throws -> [Order] {
        [order]
    }

    func fetchOrder(
        id: UUID
    ) async throws -> Order? {
        if shouldFail {
            shouldFail = false
            throw Failure()
        }

        return id == order.id ? order : nil
    }

    private struct Failure: Error {}
}

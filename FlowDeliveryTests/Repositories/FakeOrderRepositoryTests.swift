@testable import FlowDelivery
import Foundation
import Testing

struct FakeOrderRepositoryTests {
    @Test("Starts with no orders")
    func fetchOrdersStartsEmpty() async throws {
        let sut = await FakeOrderRepository()

        let orders = try await sut.fetchOrders()

        #expect(orders.isEmpty)
    }

    @Test("Fetches a created order")
    func fetchOrdersReturnsCreatedOrder() async throws {
        let sut = await FakeOrderRepository()
        let order = makeOrder()

        try await sut.createOrder(order)

        let orders = try await sut.fetchOrders()

        #expect(orders == [order])
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

    @Test("Fetches an order by identifier")
    func fetchOrderReturnsMatchingOrder() async throws {
        let firstOrder = makeOrder()
        let expectedOrder = makeOrder()

        let sut = await FakeOrderRepository(
            orders: [
                firstOrder,
                expectedOrder
            ]
        )

        let order = try await sut.fetchOrder(
            id: expectedOrder.id
        )

        #expect(order == expectedOrder)
    }

    @Test("Returns nil for an unknown identifier")
    func fetchOrderReturnsNilForUnknownIdentifier() async throws {
        let sut = await FakeOrderRepository(
            orders: [
                makeOrder()
            ]
        )

        let order = try await sut.fetchOrder(
            id: UUID()
        )

        #expect(order == nil)
    }
}

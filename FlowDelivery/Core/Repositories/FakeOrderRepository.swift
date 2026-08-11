final class FakeOrderRepository: OrderRepository {
    private(set) var orders: [Order] = []

    func createOrder(
        _ order: Order
    ) async throws {
        orders.append(order)
    }

    func fetchOrders() async throws -> [Order] {
        orders
    }
}

import Foundation

final class FakeOrderRepository: OrderRepository {
    private(set) var orders: [Order]

    init(
        orders: [Order] = []
    ) {
        self.orders = orders
    }

    func createOrder(
        _ order: Order
    ) async throws {
        orders.append(order)
    }

    func fetchOrders() async throws -> [Order] {
        orders
    }

    func fetchOrder(
        id: UUID
    ) async throws -> Order? {
        orders.first { order in
            order.id == id
        }
    }
}

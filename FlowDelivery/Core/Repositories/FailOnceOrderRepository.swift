import Foundation

final class FailOnceOrderRepository: OrderRepository {
    private(set) var orders: [Order] = []
    private var shouldFail = true

    func createOrder(
        _ order: Order
    ) async throws {
        if shouldFail {
            shouldFail = false
            throw Failure()
        }

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

    private struct Failure: Error {}
}

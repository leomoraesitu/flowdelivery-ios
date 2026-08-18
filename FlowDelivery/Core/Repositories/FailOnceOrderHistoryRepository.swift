import Foundation

final class FailOnceOrderHistoryRepository: OrderRepository {
    private var shouldFailFetching = true
    private var orders: [Order] = []

    func createOrder(
        _ order: Order
    ) async throws {
        orders.append(order)
    }

    func fetchOrders() async throws -> [Order] {
        if shouldFailFetching {
            shouldFailFetching = false
            throw Failure()
        }

        return orders
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

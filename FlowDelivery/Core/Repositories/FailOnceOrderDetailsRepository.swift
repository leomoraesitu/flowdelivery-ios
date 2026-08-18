import Foundation

final class FailOnceOrderDetailsRepository: OrderRepository {
    private var orders: [Order] = []
    private var shouldFailFetchingOrder = true

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
        if shouldFailFetchingOrder {
            shouldFailFetchingOrder = false
            throw Failure()
        }

        return orders.first { order in
            order.id == id
        }
    }

    private struct Failure: Error {}
}

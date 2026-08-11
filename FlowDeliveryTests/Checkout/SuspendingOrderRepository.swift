@testable import FlowDelivery

@MainActor
final class SuspendingOrderRepository: OrderRepository {
    private var continuation: CheckedContinuation<Void, Never>?

    private(set) var orders: [Order] = []

    func createOrder(
        _ order: Order
    ) async throws {
        orders.append(order)

        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func fetchOrders() async throws -> [Order] {
        orders
    }

    func waitUntilStarted() async {
        while orders.isEmpty {
            await Task.yield()
        }
    }

    func complete() {
        continuation?.resume()
        continuation = nil
    }
}

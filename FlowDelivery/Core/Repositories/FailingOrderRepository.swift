import Foundation

struct FailingOrderRepository: OrderRepository {
    struct Failure: Error {}

    func createOrder(
        _ order: Order
    ) async throws {
        _ = order

        throw Failure()
    }

    func fetchOrders() async throws -> [Order] {
        throw Failure()
    }

    func fetchOrder(
        id: UUID
    ) async throws -> Order? {
        _ = id

        throw Failure()
    }
}

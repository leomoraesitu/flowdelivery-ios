import Foundation

protocol OrderRepository {
    func createOrder(
        _ order: Order
    ) async throws

    func fetchOrders() async throws -> [Order]

    func fetchOrder(
        id: UUID
    ) async throws -> Order?
}

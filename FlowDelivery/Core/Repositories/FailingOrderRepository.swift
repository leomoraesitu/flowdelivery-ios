struct FailingOrderRepository: OrderRepository {
    struct Failure: Error {}

    func createOrder(
        _ order: Order
    ) async throws {
        _ = order

        throw Failure()
    }
}

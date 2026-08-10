protocol OrderRepository {
    func createOrder(
        _ order: Order
    ) async throws
}

import Foundation

final class OrderHistoryFixtureRepository: OrderRepository {
    private var orders: [Order]

    init() {
        let menuItem = MenuItem(
            id: UUID(),
            name: "Pizza Margherita",
            description: "Molho de tomate e mussarela.",
            price: Decimal(string: "49.90") ?? .zero,
            imageURL: nil
        )

        let olderOrder = Order(
            id: UUID(),
            items: [
                CartItem(
                    menuItem: menuItem,
                    quantity: 1
                )
            ],
            deliveryAddress: "Avenida Paulista, 1000",
            paymentMethod: .pix,
            createdAt: Date(
                timeIntervalSince1970: 1000
            )
        )

        let newerOrder = Order(
            id: UUID(),
            items: [
                CartItem(
                    menuItem: menuItem,
                    quantity: 2
                )
            ],
            deliveryAddress: "Avenida Paulista, 1000",
            paymentMethod: .pix,
            createdAt: Date(
                timeIntervalSince1970: 2000
            )
        )

        // A ordem do repositório é intencionalmente inversa.
        orders = [
            olderOrder,
            newerOrder
        ]
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

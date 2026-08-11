import Foundation
import Observation

@MainActor
@Observable
final class OrderDetailsViewModel {
    private let orderID: UUID
    private let repository: OrderRepository

    private(set) var state: OrderDetailsState = .loading

    enum OrderDetailsState: Equatable {
        case loading
        case loaded(Order)
        case notFound
        case error(OrderDetailsError)
    }

    enum OrderDetailsError: Equatable {
        case loadFailed
    }

    init(
        orderID: UUID,
        repository: OrderRepository
    ) {
        self.orderID = orderID
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            guard let order = try await repository.fetchOrder(
                id: orderID
            ) else {
                state = .notFound
                return
            }

            state = .loaded(order)
        } catch {
            state = .error(.loadFailed)
        }
    }
}

import Observation

@MainActor
@Observable
final class OrderHistoryViewModel {
    private let repository: OrderRepository

    private(set) var state: OrderHistoryState = .loading

    enum OrderHistoryState: Equatable {
        case loading
        case loaded([OrderHistoryEntry])
        case empty
        case error(OrderHistoryError)
    }

    enum OrderHistoryError: Equatable {
        case loadFailed
    }

    init(
        repository: OrderRepository
    ) {
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            let orders = try await repository.fetchOrders()

            let entries = orders
                .sorted { first, second in
                    first.createdAt > second.createdAt
                }
                .map(OrderHistoryEntry.init)

            if orders.isEmpty {
                state = .empty
            } else {
                state = .loaded(entries)
            }
        } catch {
            state = .error(.loadFailed)
        }
    }
}

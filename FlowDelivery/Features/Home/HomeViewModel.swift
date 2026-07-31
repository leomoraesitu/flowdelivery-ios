import Observation

@Observable
final class HomeViewModel {
    private(set) var state: HomeState = .loading
    private let repository: RestaurantRepository

    init(
        repository: RestaurantRepository
    ) {
        self.repository = repository
    }

    enum HomeState: Equatable {
        case loading
        case loaded([Restaurant])
    }

    func load() {
        state = .loaded(
            repository.fetchRestaurants()
        )
    }
}

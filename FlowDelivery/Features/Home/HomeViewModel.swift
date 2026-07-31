import Observation

@MainActor
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
        case error(HomeError)
    }

    enum HomeError: Equatable {
        case loadFailed
    }

    func load() async {
        state = .loading

        do {
            let restaurants =
                try await repository.fetchRestaurants()

            state = .loaded(restaurants)

        } catch {
            state = .error(.loadFailed)
        }
    }
}

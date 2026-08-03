import Observation

@MainActor
@Observable
final class HomeViewModel {
    private(set) var state: HomeState = .loading
    private let repository: RestaurantRepository

    private var hasLoaded = false

    init(
        repository: RestaurantRepository
    ) {
        self.repository = repository
    }

    enum HomeState: Equatable {
        case loading
        case loaded(HomeContent)
        case empty
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

            if restaurants.isEmpty {
                state = .empty
            } else {
                state = .loaded(
                    HomeContent(
                        restaurants:
                        restaurants.map(
                            RestaurantRowModel.init
                        )
                    )
                )
            }

        } catch {
            state = .error(.loadFailed)
        }
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }

        hasLoaded = true
        await load()
    }
}

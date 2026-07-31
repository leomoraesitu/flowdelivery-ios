import Observation

@Observable
final class HomeViewModel {
    private(set) var state: HomeState = .loading

    enum HomeState: Equatable {
        case loading
        case loaded
    }

    func load() {
        state = .loaded
    }
}

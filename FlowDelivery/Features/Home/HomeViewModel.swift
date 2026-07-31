import Foundation
import Observation

@Observable
final class HomeViewModel {
    private(set) var state: HomeState = .loading

    enum HomeState: Equatable {
        case loading
        case loaded([Restaurant])
    }

    func load() {
        state = .loaded([
            Restaurant(
                id: UUID(),
                name: "Pizzaria Itália"
            ),
            Restaurant(
                id: UUID(),
                name: "Burger House"
            )
        ])
    }
}

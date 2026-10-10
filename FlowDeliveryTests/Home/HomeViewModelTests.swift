@testable import FlowDelivery
import Foundation
import Testing

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {
    private func makeSut(
        repository: RestaurantRepository = FakeRestaurantRepository()
    ) -> HomeViewModel {
        HomeViewModel(repository: repository)
    }

    @Test("Starts in loading state")
    func startsInLoadingState() {
        let sut = makeSut()

        #expect(sut.state == .loading)
    }

    @Test("Displays empty state when no restaurants exist")
    func loadDisplaysEmptyState() async {
        let sut = makeSut(repository: EmptyRestaurantRepository())

        await sut.load()

        #expect(sut.state == .empty)
    }

    @Test("Displays error state when loading fails")
    func loadDisplaysErrorState() async {
        let sut = makeSut(repository: FailingRestaurantRepository())

        await sut.load()

        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Displays fetched restaurants")
    func loadDisplaysFetchedRestaurants() async throws {
        let repository = FakeRestaurantRepository()
        let restaurants = try await repository.fetchRestaurants()

        let sut = makeSut(repository: repository)

        await sut.load()

        let expected = HomeContent(
            restaurants: restaurants.map(RestaurantRowModel.init)
        )
        #expect(sut.state == .loaded(expected))
    }

    @Test("loadIfNeeded loads only once across repeated calls")
    func loadIfNeededSkipsSubsequentLoads() async {
        let repository = CountingRestaurantRepository()
        let sut = makeSut(repository: repository)

        await sut.loadIfNeeded()
        await sut.loadIfNeeded()

        #expect(repository.callCount == 1)
    }
}

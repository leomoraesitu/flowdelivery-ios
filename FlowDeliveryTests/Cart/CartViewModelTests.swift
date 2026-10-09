@testable import FlowDelivery
import Foundation
import Testing

@Suite("CartViewModel")
@MainActor
struct CartViewModelTests {
    private struct Sut {
        let viewModel: CartViewModel
        let cartStore: CartStore
    }

    private func makeSut() -> Sut {
        let cartStore = CartStore()
        let viewModel = CartViewModel(cartStore: cartStore)
        return Sut(viewModel: viewModel, cartStore: cartStore)
    }

    private func makeMenuItem(
        name: String = "Pizza Margherita",
        price: Decimal = Decimal(string: "49.90") ?? .zero
    ) -> MenuItem {
        MenuItem(
            id: UUID(),
            name: name,
            description: "Molho de tomate, mussarela e manjericão.",
            price: price,
            imageURL: nil
        )
    }

    @Test("Starts empty when the cart store has no items")
    func stateIsEmptyWhenCartStoreIsEmpty() {
        let sut = makeSut()

        #expect(sut.viewModel.state == .empty)
    }

    @Test("Reflects the cart store items and total when loaded")
    func stateIsLoadedWhenCartStoreHasItems() {
        let sut = makeSut()
        let menuItem = makeMenuItem()
        sut.cartStore.add(menuItem)

        let expected = CartViewModel.CartState.loaded(
            CartContent(
                cartItems: sut.cartStore.items,
                total: sut.cartStore.total
            )
        )

        #expect(sut.viewModel.state == expected)
    }

    @Test("Increments the quantity of an existing item")
    func incrementQuantityIncreasesItemQuantity() throws {
        let sut = makeSut()
        let menuItem = makeMenuItem()
        sut.cartStore.add(menuItem)

        sut.viewModel.incrementQuantity(itemID: menuItem.id)

        let item = try #require(
            sut.cartStore.items.first { $0.id == menuItem.id }
        )
        #expect(item.quantity == 2)
    }

    @Test("Decrements the quantity of an item above one")
    func decrementQuantityDecreasesItemQuantityAboveOne() throws {
        let sut = makeSut()
        let menuItem = makeMenuItem()
        sut.cartStore.add(menuItem)
        sut.cartStore.incrementQuantity(itemID: menuItem.id)

        sut.viewModel.decrementQuantity(itemID: menuItem.id)

        let item = try #require(
            sut.cartStore.items.first { $0.id == menuItem.id }
        )
        #expect(item.quantity == 1)
    }

    @Test("Never decrements a single item below one")
    func decrementQuantityKeepsSingleItemAtOne() throws {
        let sut = makeSut()
        let menuItem = makeMenuItem()
        sut.cartStore.add(menuItem)

        sut.viewModel.decrementQuantity(itemID: menuItem.id)

        let item = try #require(
            sut.cartStore.items.first { $0.id == menuItem.id }
        )
        #expect(item.quantity == 1)
    }

    @Test("Removes an item and returns to empty when it was the last one")
    func removeItemClearsLastItemBackToEmpty() {
        let sut = makeSut()
        let menuItem = makeMenuItem()
        sut.cartStore.add(menuItem)

        sut.viewModel.removeItem(itemID: menuItem.id)

        #expect(sut.viewModel.state == .empty)
    }

    @Test("Clears every item regardless of quantity")
    func clearCartEmptiesTheStoreRegardlessOfQuantity() {
        let sut = makeSut()
        let menuItem = makeMenuItem()
        sut.cartStore.add(menuItem)
        sut.cartStore.incrementQuantity(itemID: menuItem.id)

        sut.viewModel.clearCart()

        #expect(sut.viewModel.state == .empty)
    }
}

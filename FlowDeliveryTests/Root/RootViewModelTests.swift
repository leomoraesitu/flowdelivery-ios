@testable import FlowDelivery
import Foundation
import Testing

@Suite("RootViewModel")
@MainActor
struct RootViewModelTests {
    private struct Sut {
        let viewModel: RootViewModel
        let sessionStore: SessionStore
        let credentialStore: SessionCredentialStore
        let cartStore: CartStore
    }

    private func makeSut(
        credentialStore: SessionCredentialStore = FakeSessionCredentialStore()
    ) -> Sut {
        let sessionStore = SessionStore()
        let cartStore = CartStore()
        let authService = AuthService(
            repository: FakeAuthRepository(),
            sessionCredentialStore: credentialStore,
            sessionStore: sessionStore
        )
        let viewModel = RootViewModel(
            sessionStore: sessionStore,
            authService: authService,
            cartStore: cartStore
        )
        return Sut(
            viewModel: viewModel,
            sessionStore: sessionStore,
            credentialStore: credentialStore,
            cartStore: cartStore
        )
    }

    private func signIn(_ sut: Sut) throws {
        let session = UserSession(userID: UUID(), accessToken: "abc")
        try sut.credentialStore.save(session)
        sut.sessionStore.login(with: session)
        sut.cartStore.add(
            MenuItem(
                id: UUID(),
                name: "Pizza Margherita",
                description: "Molho de tomate, mussarela e manjericão.",
                price: Decimal(string: "49.90") ?? .zero,
                imageURL: nil
            )
        )
        try #require(sut.sessionStore.session != nil)
        try #require(!sut.cartStore.items.isEmpty)
    }

    @Test("signOut clears session and credential")
    func signOutClearsSessionAndCredential() throws {
        let sut = makeSut()
        try signIn(sut)

        sut.viewModel.signOut()

        #expect(sut.sessionStore.session == nil)
        #expect(try sut.credentialStore.load() == nil)
        #expect(sut.viewModel.rootState == .unauthenticated)
    }

    @Test("signOut clears the cart")
    func signOutClearsTheCart() throws {
        let sut = makeSut()
        try signIn(sut)

        sut.viewModel.signOut()

        #expect(sut.cartStore.items.isEmpty)
    }

    @Test("signOut does not publish an error on success")
    func signOutDoesNotPublishAnErrorOnSuccess() throws {
        let sut = makeSut()
        try signIn(sut)

        sut.viewModel.signOut()

        #expect(sut.viewModel.signOutError == nil)
    }

    @Test("signOut still clears state and cart when credential removal fails")
    func signOutStillClearsStateAndCartWhenCredentialRemovalFails() throws {
        let sut = makeSut(credentialStore: FailingDeleteStore())
        try signIn(sut)

        sut.viewModel.signOut()

        #expect(sut.sessionStore.session == nil)
        #expect(sut.cartStore.items.isEmpty)
    }

    @Test("signOut publishes an error when credential removal fails")
    func signOutPublishesAnErrorWhenCredentialRemovalFails() throws {
        let sut = makeSut(credentialStore: FailingDeleteStore())
        try signIn(sut)

        sut.viewModel.signOut()

        #expect(sut.viewModel.signOutError == .credentialNotRemoved)
    }

    @Test("dismissing the error clears it")
    func dismissingTheErrorClearsIt() throws {
        let sut = makeSut(credentialStore: FailingDeleteStore())
        try signIn(sut)
        sut.viewModel.signOut()
        try #require(sut.viewModel.signOutError != nil)

        sut.viewModel.dismissSignOutError()

        #expect(sut.viewModel.signOutError == nil)
    }
}

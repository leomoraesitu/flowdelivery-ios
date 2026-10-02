@testable import FlowDelivery
import Foundation
import Testing

@Suite("AuthenticationViewModel")
@MainActor
struct AuthenticationViewModelTests {
    private func makeSut(
        credentialStore: SessionCredentialStore = FakeSessionCredentialStore()
    ) -> (viewModel: AuthenticationViewModel, sessionStore: SessionStore) {
        let sessionStore = SessionStore()
        let authService = AuthService(
            repository: FakeAuthRepository(),
            sessionCredentialStore: credentialStore,
            sessionStore: sessionStore
        )
        let viewModel = AuthenticationViewModel(
            authService: authService
        )
        return (viewModel, sessionStore)
    }

    @Test("signing in publishes a session")
    func signingInPublishesASession() {
        let (viewModel, sessionStore) = makeSut()

        viewModel.signInButtonTapped()

        #expect(sessionStore.session != nil)
        #expect(viewModel.authenticationState == .idle)
    }

    @Test("signing in persists the same session it publishes")
    func signingInPersistsTheSameSession() throws {
        let credentialStore = FakeSessionCredentialStore()
        let (viewModel, sessionStore) = makeSut(credentialStore: credentialStore)

        viewModel.signInButtonTapped()

        #expect(try credentialStore.load() == sessionStore.session)
    }

    @Test("a failed sign-in shows loginFailed and publishes no session")
    func failedSignInShowsLoginFailed() {
        let (viewModel, sessionStore) = makeSut(credentialStore: FailingSaveStore())

        viewModel.signInButtonTapped()

        #expect(viewModel.authenticationState == .error(.loginFailed))
        #expect(sessionStore.session == nil)
    }

    @Test("a successful sign-in clears a previous error")
    func successfulSignInClearsPreviousError() {
        let (viewModel, _) = makeSut(credentialStore: FailFirstSaveStore())

        viewModel.signInButtonTapped()
        #expect(viewModel.authenticationState == .error(.loginFailed))

        viewModel.signInButtonTapped()
        #expect(viewModel.authenticationState == .idle)
    }
}

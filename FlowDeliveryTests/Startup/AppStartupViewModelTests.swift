@testable import FlowDelivery
import Foundation
import Testing

@Suite("AppStartupViewModel")
@MainActor
struct AppStartupViewModelTests {
    private struct Sut {
        let authService: AuthService
        let sessionStore: SessionStore
    }

    private func makeSut(
        credentialStore: SessionCredentialStore = FakeSessionCredentialStore()
    ) -> Sut {
        let sessionStore = SessionStore()
        let authService = AuthService(
            repository: FakeAuthRepository(),
            sessionCredentialStore: credentialStore,
            sessionStore: sessionStore
        )
        return Sut(authService: authService, sessionStore: sessionStore)
    }

    @Test
    func startsIdle() {
        let sut = AppStartupViewModel(authService: makeSut().authService)

        #expect(sut.state == .idle)
    }

    @Test
    func readyAfterRestoringAnExistingSession() {
        let stored = UserSession(userID: UUID(), accessToken: "abc")
        let dependencies = makeSut(
            credentialStore: FakeSessionCredentialStore(initialSession: stored)
        )
        let sut = AppStartupViewModel(authService: dependencies.authService)

        sut.start()

        #expect(sut.state == .ready)
        #expect(dependencies.sessionStore.session == stored)
    }

    @Test
    func readyEvenWhenTheKeychainFailsToLoad() {
        let dependencies = makeSut(credentialStore: FailingLoadStore())
        let sut = AppStartupViewModel(authService: dependencies.authService)

        sut.start()

        #expect(sut.state == .ready)
        #expect(dependencies.sessionStore.session == nil)
    }
}

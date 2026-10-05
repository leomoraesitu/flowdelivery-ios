@testable import FlowDelivery
import Foundation
import Testing

@Suite("AppStartupViewModel")
@MainActor
struct AppStartupViewModelTests {
    private func makeAuthService(
        credentialStore: SessionCredentialStore = FakeSessionCredentialStore()
    ) -> AuthService {
        AuthService(
            repository: FakeAuthRepository(),
            sessionCredentialStore: credentialStore,
            sessionStore: SessionStore()
        )
    }

    @Test
    func startsIdle() {
        let sut = AppStartupViewModel(authService: makeAuthService())

        #expect(sut.state == .idle)
    }

    @Test
    func readyAfterRestoringAnExistingSession() {
        let stored = UserSession(userID: UUID(), accessToken: "abc")
        let authService = makeAuthService(
            credentialStore: FakeSessionCredentialStore(initialSession: stored)
        )
        let sut = AppStartupViewModel(authService: authService)

        sut.start()

        #expect(sut.state == .ready)
    }

    @Test
    func readyEvenWhenTheKeychainFailsToLoad() {
        let authService = makeAuthService(credentialStore: FailingLoadStore())
        let sut = AppStartupViewModel(authService: authService)

        sut.start()

        #expect(sut.state == .ready)
    }
}

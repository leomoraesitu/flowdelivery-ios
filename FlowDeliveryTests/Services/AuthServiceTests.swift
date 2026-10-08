@testable import FlowDelivery
import Foundation
import Testing

@Suite("AuthService")
struct AuthServiceTests {
    private struct RejectingAuthRepository: AuthRepository {
        func login() -> UserSession? {
            nil
        }

        func logout() {}

        func restoreSession(_ session: UserSession) -> UserSession? {
            nil
        }
    }

    private struct RenewingAuthRepository: AuthRepository {
        let renewed: UserSession

        func login() -> UserSession? {
            nil
        }

        func logout() {}

        func restoreSession(_ session: UserSession) -> UserSession? {
            renewed
        }
    }

    private func makeService(
        repository: AuthRepository = FakeAuthRepository(),
        credentialStore: SessionCredentialStore = FakeSessionCredentialStore()
    ) -> (service: AuthService, sessionStore: SessionStore) {
        let sessionStore = SessionStore()
        let service = AuthService(
            repository: repository,
            sessionCredentialStore: credentialStore,
            sessionStore: sessionStore
        )
        return (service, sessionStore)
    }

    @Test
    func loginPersistsTheSameSessionItPublishes() throws {
        let credentialStore = FakeSessionCredentialStore()
        let (service, sessionStore) = makeService(credentialStore: credentialStore)

        try service.login()

        let published = try #require(sessionStore.session)
        #expect(try credentialStore.load() == published)
    }

    @Test
    func restoreSessionKeepsTheSameUserID() throws {
        let stored = UserSession(userID: UUID(), accessToken: "abc")
        let (service, sessionStore) = makeService(
            credentialStore: FakeSessionCredentialStore(initialSession: stored)
        )

        try service.restoreSession()

        #expect(sessionStore.session == stored)
    }

    @Test
    func restoreSessionPurgesCredentialRejectedByTheBackend() throws {
        let credentialStore = FakeSessionCredentialStore(
            initialSession: UserSession(userID: UUID(), accessToken: "abc")
        )
        let (service, sessionStore) = makeService(
            repository: RejectingAuthRepository(),
            credentialStore: credentialStore
        )

        try service.restoreSession()

        #expect(sessionStore.session == nil)
        #expect(try credentialStore.load() == nil)
    }

    @Test
    func loginThrowsWhenRepositoryYieldsNoSession() throws {
        let credentialStore = FakeSessionCredentialStore()
        let (service, sessionStore) = makeService(
            repository: RejectingAuthRepository(),
            credentialStore: credentialStore
        )

        #expect(throws: AuthServiceError.loginRejected) {
            try service.login()
        }

        #expect(sessionStore.session == nil)
        #expect(try credentialStore.load() == nil)
    }

    @Test
    func logoutClearsStateAndCredential() throws {
        let credentialStore = FakeSessionCredentialStore()
        let (service, sessionStore) = makeService(credentialStore: credentialStore)
        try service.login()

        try service.logout()

        #expect(sessionStore.session == nil)
        #expect(try credentialStore.load() == nil)
    }

    @Test
    func logoutClearsInMemoryStateEvenWhenDeletingTheCredentialFails() {
        let (service, sessionStore) = makeService(credentialStore: FailingDeleteStore())
        sessionStore.login(with: UserSession(userID: UUID(), accessToken: "abc"))

        #expect(throws: FailingDeleteStore.DeleteFailed.self) {
            try service.logout()
        }
        #expect(sessionStore.session == nil)
    }

    @Test
    func restoreSessionPersistsTheSessionReturnedByTheBackend() throws {
        let stored = UserSession(userID: UUID(), accessToken: "stale")
        let renewed = UserSession(userID: stored.userID, accessToken: "renewed")
        let credentialStore = FakeSessionCredentialStore(initialSession: stored)
        let (service, sessionStore) = makeService(
            repository: RenewingAuthRepository(renewed: renewed),
            credentialStore: credentialStore
        )

        try service.restoreSession()

        #expect(sessionStore.session == renewed)
        #expect(try credentialStore.load() == renewed)
    }
}

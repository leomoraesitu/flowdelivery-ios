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

    private struct FailingDeleteStore: SessionCredentialStore {
        struct DeleteFailed: Error {}

        func load() throws -> UserSession? {
            nil
        }

        func save(_ session: UserSession) throws {}

        func delete() throws {
            throw DeleteFailed()
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
}

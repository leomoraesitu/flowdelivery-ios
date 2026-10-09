@testable import FlowDelivery
import Foundation
import Testing

@MainActor
struct AppContainerTests {
    @Test
    func initUsesTheInjectedCredentialStore() throws {
        let credentialStore = FakeSessionCredentialStore()
        let container = AppContainer(credentialStore: credentialStore)

        try container.authService.login()

        let savedSession = try #require(try credentialStore.load())
        #expect(savedSession.accessToken.isEmpty == false)
    }
}

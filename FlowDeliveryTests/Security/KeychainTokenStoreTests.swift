@testable import FlowDelivery
import Foundation
import Security
import Testing

struct KeychainTokenStoreTests {
    private func makeStore() -> KeychainTokenStore {
        KeychainTokenStore(
            service: "com.flowdelivery.tests.\(UUID().uuidString)",
            account: "access-token"
        )
    }

    @Test
    func loadReturnsNilWhenNothingWasSaved() throws {
        let store = makeStore()
        defer { try? store.delete() }

        #expect(try store.load() == nil)
    }

    @Test
    func loadReturnsSavedToken() throws {
        let store = makeStore()
        defer { try? store.delete() }

        try store.save("token-abc")

        #expect(try store.load() == "token-abc")
    }

    @Test
    func saveOverwritesExistingToken() throws {
        let store = makeStore()
        defer { try? store.delete() }

        try store.save("first-token")
        try store.save("second-token")

        #expect(try store.load() == "second-token")
    }

    @Test
    func deleteRemovesToken() throws {
        let store = makeStore()
        defer { try? store.delete() }

        try store.save("token-abc")
        try store.delete()

        #expect(try store.load() == nil)
    }

    @Test
    func deleteSucceedsWhenItemDoesNotExist() throws {
        let store = makeStore()

        #expect(throws: Never.self) {
            try store.delete()
        }
    }

    @Test
    func savedTokenIsRestrictedToThisDeviceWhenUnlocked() throws {
        let service = "com.flowdelivery.tests.\(UUID().uuidString)"
        let account = "access-token"

        let store = KeychainTokenStore(
            service: service,
            account: account
        )
        defer { try? store.delete() }

        try store.save("token-abc")

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        #expect(status == errSecSuccess)

        let attributes = try #require(
            result as? [String: Any]
        )

        let accessible = attributes[
            kSecAttrAccessible as String
        ] as? String

        #expect(
            accessible == kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        )
    }
}

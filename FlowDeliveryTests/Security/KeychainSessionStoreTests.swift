@testable import FlowDelivery
import Foundation
import Security
import Testing

@Suite("KeychainSessionStore")
struct KeychainSessionStoreTests {
    private struct Fixture {
        let store: KeychainSessionStore
        let service: String
        let account: String
    }

    private func makeFixture() -> Fixture {
        let service = "com.flowdelivery.tests.\(UUID().uuidString)"
        let account = "user-session"
        return Fixture(
            store: KeychainSessionStore(service: service, account: account),
            service: service,
            account: account
        )
    }

    private func query(_ fixture: Fixture) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: fixture.service,
            kSecAttrAccount as String: fixture.account
        ]
    }

    private func writeRaw(_ data: Data, to fixture: Fixture) {
        var attributes = query(fixture)
        attributes[kSecValueData as String] = data
        let status = SecItemAdd(attributes as CFDictionary, nil)
        #expect(status == errSecSuccess)
    }

    private func readRaw(from fixture: Fixture) -> Data? {
        var attributes = query(fixture)
        attributes[kSecReturnData as String] = true
        attributes[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        guard SecItemCopyMatching(attributes as CFDictionary, &result) == errSecSuccess else {
            return nil
        }
        return result as? Data
    }

    @Test
    func loadReturnsNilWhenNothingSaved() throws {
        let fixture = makeFixture()
        defer { try? fixture.store.delete() }

        #expect(try fixture.store.load() == nil)
    }

    @Test
    func loadReturnsSavedSessionWithSameUserID() throws {
        let fixture = makeFixture()
        defer { try? fixture.store.delete() }
        let session = UserSession(userID: UUID(), accessToken: "abc")

        try fixture.store.save(session)

        #expect(try fixture.store.load() == session)
    }

    @Test
    func saveOverwritesPreviousSession() throws {
        let fixture = makeFixture()
        defer { try? fixture.store.delete() }
        let second = UserSession(userID: UUID(), accessToken: "second")

        try fixture.store.save(UserSession(userID: UUID(), accessToken: "first"))
        try fixture.store.save(second)

        #expect(try fixture.store.load() == second)
    }

    @Test
    func deleteRemovesSession() throws {
        let fixture = makeFixture()
        defer { try? fixture.store.delete() }

        try fixture.store.save(UserSession(userID: UUID(), accessToken: "abc"))
        try fixture.store.delete()

        #expect(try fixture.store.load() == nil)
    }

    @Test
    func deleteSucceedsWhenItemDoesNotExist() {
        let fixture = makeFixture()

        #expect(throws: Never.self) {
            try fixture.store.delete()
        }
    }

    @Test
    func loadFailsClosedAndPurgesCorruptedData() throws {
        let fixture = makeFixture()
        defer { try? fixture.store.delete() }
        writeRaw(Data("not-json".utf8), to: fixture)

        #expect(try fixture.store.load() == nil)
        #expect(readRaw(from: fixture) == nil)
    }

    @Test
    func loadFailsClosedAndPurgesUnknownVersion() throws {
        let fixture = makeFixture()
        defer { try? fixture.store.delete() }
        let future = StoredSession(version: 999, userID: UUID(), accessToken: "abc")
        let encoded = try JSONEncoder().encode(future)
        writeRaw(encoded, to: fixture)

        #expect(try fixture.store.load() == nil)
        #expect(readRaw(from: fixture) == nil)
    }

    @Test
    func savedSessionIsRestrictedToThisDeviceWhenUnlocked() throws {
        let fixture = makeFixture()
        defer { try? fixture.store.delete() }
        try fixture.store.save(UserSession(userID: UUID(), accessToken: "abc"))

        var attributesQuery = query(fixture)
        attributesQuery[kSecReturnAttributes as String] = true
        attributesQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(attributesQuery as CFDictionary, &result)
        #expect(status == errSecSuccess)

        let attributes = try #require(result as? [String: Any])
        let accessible = attributes[kSecAttrAccessible as String] as? String
        #expect(accessible == kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String)
    }
}

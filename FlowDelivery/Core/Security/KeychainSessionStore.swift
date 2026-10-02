@preconcurrency import Foundation
@preconcurrency import Security

enum KeychainSessionStoreError: Error {
    case encodingFailed
    case unexpectedResultType
    case unhandledStatus(OSStatus)
}

final class KeychainSessionStore: SessionCredentialStore {
    private let service: String
    private let account: String
    private let accessibility: CFString

    init(
        service: String = "com.flowdelivery.authentication",
        account: String = "user-session",
        accessibility: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ) {
        self.service = service
        self.account = account
        self.accessibility = accessibility
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    func save(_ session: UserSession) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(StoredSession(session))
        } catch {
            throw KeychainSessionStoreError.encodingFailed
        }

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility
        ]
        let updateStatus = SecItemUpdate(
            baseQuery as CFDictionary,
            attributes as CFDictionary
        )

        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            try add(data)
        default:
            throw KeychainSessionStoreError.unhandledStatus(updateStatus)
        }
    }

    func load() throws -> UserSession? {
        // Real Keychain errors propagate from here, outside any decode handling.
        guard let data = try readData() else { return nil }

        // Only decoding is guarded: unreadable or outdated payloads fail closed.
        guard
            let stored = try? JSONDecoder().decode(StoredSession.self, from: data),
            stored.version == StoredSession.currentVersion
        else {
            try delete()
            return nil
        }
        return stored.session
    }

    func delete() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainSessionStoreError.unhandledStatus(status)
        }
    }

    // MARK: - Private

    private func add(_ data: Data) throws {
        var query = baseQuery
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = accessibility

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainSessionStoreError.unhandledStatus(status)
        }
    }

    private func readData() throws -> Data? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainSessionStoreError.unexpectedResultType
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainSessionStoreError.unhandledStatus(status)
        }
    }
}

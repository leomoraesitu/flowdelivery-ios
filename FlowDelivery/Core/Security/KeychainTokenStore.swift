import Foundation
import Security

enum KeychainTokenStoreError: Error {
    case encodingFailed
    case decodingFailed
    case unhandledStatus(OSStatus)
}

final class KeychainTokenStore: TokenStore {
    private let service: String
    private let account: String
    private let accessibility: CFString

    init(
        service: String = "com.flowdelivery.authentication",
        account: String = "access-token",
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

    func save(_ accessToken: String) throws {
        guard let tokenData = accessToken.data(
            using: .utf8
        ) else {
            throw KeychainTokenStoreError.encodingFailed
        }

        let attributes: [String: Any] = [
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: accessibility
        ]

        let updateStatus = SecItemUpdate(
            baseQuery as CFDictionary,
            attributes as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw KeychainTokenStoreError.unhandledStatus(
                updateStatus
            )
        }

        var addQuery = baseQuery
        addQuery[kSecValueData as String] = tokenData
        addQuery[kSecAttrAccessible as String] = accessibility

        let addStatus = SecItemAdd(
            addQuery as CFDictionary,
            nil
        )

        guard addStatus == errSecSuccess else {
            throw KeychainTokenStoreError.unhandledStatus(
                addStatus
            )
        }
    }

    func load() throws -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainTokenStoreError.unhandledStatus(
                status
            )
        }

        guard
            let data = result as? Data,
            let accessToken = String(
                data: data,
                encoding: .utf8
            )
        else {
            throw KeychainTokenStoreError.decodingFailed
        }

        return accessToken
    }

    func delete() throws {
        let status = SecItemDelete(
            baseQuery as CFDictionary
        )

        guard status == errSecSuccess
            || status == errSecItemNotFound
        else {
            throw KeychainTokenStoreError.unhandledStatus(
                status
            )
        }
    }
}

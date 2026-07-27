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

    init(
        service: String = "com.flowdelivery.authentication",
        account: String = "access-token"
    ) {
        self.service = service
        self.account = account
    }

    func save(_ accessToken: String) throws {
        guard let tokenData = accessToken.data(
            using: .utf8
        ) else {
            throw KeychainTokenStoreError.encodingFailed
        }

        try delete()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: tokenData
        ]

        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )

        guard status == errSecSuccess else {
            throw KeychainTokenStoreError.unhandledStatus(
                status
            )
        }
    }

    func load() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

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
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(
            query as CFDictionary
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

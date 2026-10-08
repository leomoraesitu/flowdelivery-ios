import Foundation

/// `delete()` sempre falha; `load`/`save` funcionam como
/// `FakeSessionCredentialStore`, para permitir login normal em UI tests
/// que precisam simular uma falha real de Keychain na remoção da sessão.
struct FailingDeleteSessionCredentialStore: SessionCredentialStore {
    struct DeleteFailed: Error {}

    private let storage = FakeSessionCredentialStore()

    func load() throws -> UserSession? {
        try storage.load()
    }

    func save(_ session: UserSession) throws {
        try storage.save(session)
    }

    func delete() throws {
        throw DeleteFailed()
    }
}

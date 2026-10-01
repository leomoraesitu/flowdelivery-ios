import os

protocol SessionCredentialStore: Sendable {
    func load() throws -> UserSession?
    func save(_ session: UserSession) throws
    func delete() throws
}

/// In-memory store for previews, unit tests and UI tests.
final class FakeSessionCredentialStore: SessionCredentialStore, @unchecked Sendable {
    private let storage: OSAllocatedUnfairLock<UserSession?>

    init(initialSession: UserSession? = nil) {
        storage = OSAllocatedUnfairLock(initialState: initialSession)
    }

    func load() throws -> UserSession? {
        storage.withLock { $0 }
    }

    func save(_ session: UserSession) throws {
        storage.withLock { $0 = session }
    }

    func delete() throws {
        storage.withLock { $0 = nil }
    }
}

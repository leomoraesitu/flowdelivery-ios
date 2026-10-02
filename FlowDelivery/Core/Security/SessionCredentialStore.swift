import os

nonisolated protocol SessionCredentialStore: Sendable {
    func load() throws -> UserSession?
    func save(_ session: UserSession) throws
    func delete() throws
}

// In-memory store for previews, unit tests and UI tests.

final class FakeSessionCredentialStore: SessionCredentialStore, @unchecked Sendable {
    private let storage: OSAllocatedUnfairLock<UserSession?>

    nonisolated init(initialSession: UserSession? = nil) {
        storage = OSAllocatedUnfairLock(initialState: initialSession)
    }

    nonisolated func load() throws -> UserSession? {
        storage.withLock { $0 }
    }

    nonisolated func save(_ session: UserSession) throws {
        storage.withLock { $0 = session }
    }

    nonisolated func delete() throws {
        storage.withLock { $0 = nil }
    }
}

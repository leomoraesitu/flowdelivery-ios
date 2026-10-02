@testable import FlowDelivery
import os

final class FailFirstSaveStore: SessionCredentialStore, @unchecked Sendable {
    struct SaveFailed: Error {}

    private let hasFailedOnce = OSAllocatedUnfairLock(initialState: false)

    func load() throws -> UserSession? {
        nil
    }

    func save(_ session: UserSession) throws {
        let shouldThrow = hasFailedOnce.withLock { failedOnce -> Bool in
            guard !failedOnce else { return false }
            failedOnce = true
            return true
        }

        if shouldThrow {
            throw SaveFailed()
        }
    }

    func delete() throws {}
}

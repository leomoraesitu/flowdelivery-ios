@testable import FlowDelivery
import Foundation

struct FailingDeleteStore: SessionCredentialStore {
    struct DeleteFailed: Error {}

    func load() throws -> UserSession? {
        nil
    }

    func save(_ session: UserSession) throws {}

    func delete() throws {
        throw DeleteFailed()
    }
}

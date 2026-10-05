@testable import FlowDelivery
import Foundation

struct FailingLoadStore: SessionCredentialStore {
    struct LoadFailed: Error {}

    func load() throws -> UserSession? {
        throw LoadFailed()
    }

    func save(_ session: UserSession) throws {}

    func delete() throws {}
}

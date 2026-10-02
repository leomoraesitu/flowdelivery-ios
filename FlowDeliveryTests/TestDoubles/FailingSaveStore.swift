@testable import FlowDelivery

struct FailingSaveStore: SessionCredentialStore {
    struct SaveFailed: Error {}

    func load() throws -> UserSession? {
        nil
    }

    func save(_ session: UserSession) throws {
        throw SaveFailed()
    }

    func delete() throws {}
}

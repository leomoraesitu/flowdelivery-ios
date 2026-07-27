protocol TokenStore {
    func save(_ accessToken: String) throws
    func load() throws -> String?
    func delete() throws
}

final class FakeTokenStore: TokenStore {
    private var token: String?

    func save(_ accessToken: String) throws {
        token = accessToken
    }

    func load() throws -> String? {
        token
    }

    func delete() throws {
        token = nil
    }
}

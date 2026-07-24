protocol TokenStore {
    func save(_ accessToken: String)

    func load() -> String?

    func delete()
}

final class FakeTokenStore: TokenStore {
    private var token: String?

    func save(_ accessToken: String) {
        token = accessToken
    }

    func load() -> String? {
        token
    }

    func delete() {
        token = nil
    }
}

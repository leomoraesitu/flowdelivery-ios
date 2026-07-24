import Observation

@Observable
final class SessionStore {
    private(set) var session: UserSession?

    var isLoggedIn: Bool {
        session != nil
    }

    func login(with session: UserSession) {
        self.session = session
    }

    func logout() {
        session = nil
    }
}

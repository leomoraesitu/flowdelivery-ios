import Observation

@Observable
final class SessionStore {
    private(set) var isLoggedIn = false

    func login() {
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
    }
}

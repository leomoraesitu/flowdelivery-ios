import Foundation

protocol AuthRepository {
    func login() -> Bool
    func logout()
}

final class FakeAuthRepository: AuthRepository {
    func login() -> Bool {
        true
    }

    func logout() {}
}

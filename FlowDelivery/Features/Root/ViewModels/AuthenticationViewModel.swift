import Observation
import SwiftUI

@Observable
final class AuthenticationViewModel {
    private let authService: AuthService
    private let sessionStore: SessionStore

    private(set) var authenticationState: AuthenticationState

    var isLoggedIn: Bool {
        sessionStore.isLoggedIn
    }

    enum AuthenticationError: Equatable {
        case loginFailed
        case logoutFailed
        case tokenStorageFailed
    }

    enum AuthenticationState: Equatable {
        case idle
        case loading
        case authenticated
        case unauthenticated
        case error(AuthenticationError)
    }

    init(
        sessionStore: SessionStore,
        authService: AuthService
    ) {
        self.sessionStore = sessionStore
        self.authService = authService

        authenticationState = sessionStore.isLoggedIn
            ? .authenticated
            : .unauthenticated
    }

    func authenticationButtonTapped() {
        let wasLoggedIn = sessionStore.isLoggedIn

        authenticationState = .loading

        do {
            if wasLoggedIn {
                try authService.logout()
                authenticationState = .unauthenticated
            } else {
                try authService.login()
                authenticationState = .authenticated
            }
        } catch {
            authenticationState = .error(
                wasLoggedIn
                    ? .logoutFailed
                    : .loginFailed
            )
        }
    }
}

extension AuthenticationViewModel.AuthenticationError {
    var message: LocalizedStringKey {
        switch self {
        case .loginFailed:
            "Não foi possível entrar. Tente novamente."

        case .logoutFailed:
            "Não foi possível encerrar a sessão."

        case .tokenStorageFailed:
            "Não foi possível acessar suas credenciais."
        }
    }
}

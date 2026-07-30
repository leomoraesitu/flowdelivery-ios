import Observation
import SwiftUI

@Observable
final class RootViewModel {
    private let sessionStore: SessionStore
    private let authService: AuthService

    private(set) var authenticationState: AuthenticationState
    private(set) var rootState: RootState

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

    enum RootState: Equatable {
        case loading
        case authenticated
        case unauthenticated
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

        rootState = sessionStore.isLoggedIn
            ? .authenticated
            : .unauthenticated
    }

    var isLoggedIn: Bool {
        sessionStore.isLoggedIn
    }

    func authenticationButtonTapped() {
        let wasLoggedIn = sessionStore.isLoggedIn

        authenticationState = .loading
        rootState = .loading

        do {
            if wasLoggedIn {
                try authService.logout()
                authenticationState = .unauthenticated
                rootState = .unauthenticated
            } else {
                try authService.login()
                authenticationState = .authenticated
                rootState = .authenticated
            }
        } catch {
            authenticationState = .error(
                wasLoggedIn
                    ? .logoutFailed
                    : .loginFailed
            )
            rootState = wasLoggedIn
                ? .authenticated
                : .unauthenticated
        }
    }
}

extension RootViewModel.AuthenticationError {
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

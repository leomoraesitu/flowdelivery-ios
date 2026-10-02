import Observation
import SwiftUI

@Observable
final class AuthenticationViewModel {
    enum AuthenticationError: Equatable {
        case loginFailed
    }

    enum AuthenticationState: Equatable {
        case idle
        case loading
        case error(AuthenticationError)
    }

    private let authService: AuthService

    private(set) var authenticationState: AuthenticationState = .idle

    init(authService: AuthService) {
        self.authService = authService
    }

    func signInButtonTapped() {
        authenticationState = .loading

        do {
            try authService.login()
            // This view model outlives its view (RootViewModel owns it), so it
            // returns to idle instead of describing a state nobody is looking at.
            authenticationState = .idle
        } catch {
            authenticationState = .error(.loginFailed)
        }
    }
}

extension AuthenticationViewModel.AuthenticationError {
    var message: LocalizedStringKey {
        switch self {
        case .loginFailed:
            "Não foi possível entrar. Tente novamente."
        }
    }
}

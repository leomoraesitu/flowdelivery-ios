import Observation

@Observable
final class RootViewModel {
    enum RootState: Equatable {
        case authenticated
        case unauthenticated
    }

    private let sessionStore: SessionStore

    let authenticationViewModel: AuthenticationViewModel

    var rootState: RootState {
        sessionStore.isLoggedIn
            ? .authenticated
            : .unauthenticated
    }

    init(
        sessionStore: SessionStore,
        authService: AuthService
    ) {
        self.sessionStore = sessionStore
        authenticationViewModel =
            AuthenticationViewModel(
                sessionStore: sessionStore,
                authService: authService
            )
    }
}

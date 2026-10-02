import Observation

@MainActor
@Observable
final class RootViewModel {
    enum RootState: Equatable {
        case authenticated
        case unauthenticated
    }

    enum SignOutError: Equatable { case credentialNotRemoved }

    private let sessionStore: SessionStore
    private let authService: AuthService
    private let cartStore: CartStore

    let authenticationViewModel: AuthenticationViewModel
    private(set) var signOutError: SignOutError?

    var rootState: RootState {
        sessionStore.isLoggedIn
            ? .authenticated
            : .unauthenticated
    }

    init(
        sessionStore: SessionStore,
        authService: AuthService,
        cartStore: CartStore
    ) {
        self.sessionStore = sessionStore
        self.authService = authService
        self.cartStore = cartStore
        authenticationViewModel =
            AuthenticationViewModel(
                authService: authService
            )
    }

    func signOut() {
        // The cart belongs to the session: clear it even if the credential
        // could not be removed, mirroring AuthService.logout().
        defer { cartStore.clear() }

        do {
            try authService.logout()
        } catch {
            signOutError = .credentialNotRemoved
        }
    }

    func dismissSignOutError() {
        signOutError = nil
    }
}

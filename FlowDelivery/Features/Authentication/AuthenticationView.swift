import SwiftUI

struct AuthenticationView: View {
    let viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Text("Usuário não autenticado")
                .font(.title)

            Button("Entrar") {
                viewModel.signInButtonTapped()
            }
            .buttonStyle(PrimaryButtonStyle())

            if case let .error(error) = viewModel.authenticationState {
                Text(error.message)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    let sessionStore = SessionStore()
    let credentialStore = FakeSessionCredentialStore()
    let authRepository = FakeAuthRepository()
    let authService = AuthService(
        repository: authRepository,
        sessionCredentialStore: credentialStore,
        sessionStore: sessionStore
    )

    AuthenticationView(
        viewModel: AuthenticationViewModel(
            authService: authService
        )
    )
    .padding(AppSpacing.large)
}

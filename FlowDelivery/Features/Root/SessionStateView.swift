import SwiftUI

struct SessionStateView: View {
    let viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Text(
                viewModel.isLoggedIn
                    ? "Usuário autenticado"
                    : "Usuário não autenticado"
            )
            .font(.title)

            Button(
                viewModel.isLoggedIn
                    ? "Sair"
                    : "Entrar"
            ) {
                viewModel.authenticationButtonTapped()
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
    let tokenStore = FakeTokenStore()
    let authRepository = FakeAuthRepository()
    let authService = AuthService(
        repository: authRepository,
        tokenStore: tokenStore,
        sessionStore: sessionStore
    )

    SessionStateView(
        viewModel: AuthenticationViewModel(
            sessionStore: sessionStore,
            authService: authService
        )
    )
    .padding(AppSpacing.large)
}

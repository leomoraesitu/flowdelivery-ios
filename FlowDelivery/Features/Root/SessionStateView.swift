import SwiftUI

struct SessionStateView: View {
    let viewModel: RootViewModel

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
                do {
                    try viewModel.authenticationButtonTapped()
                } catch {
                    // Tratamento temporário até a introdução do estado de erro na ViewModel.
                }
            }

            .buttonStyle(PrimaryButtonStyle())
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
        viewModel: RootViewModel(
            sessionStore: sessionStore,
            authService: authService
        )
    )
    .padding(AppSpacing.large)
}

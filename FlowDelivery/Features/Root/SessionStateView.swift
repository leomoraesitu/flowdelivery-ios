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
                viewModel.authenticationButtonTapped()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

#Preview {
    let sessionStore = SessionStore()
    let authService = AuthService(
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

import SwiftUI

struct SessionStateView: View {
    @Environment(SessionStore.self)
    private var sessionStore

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Text(
                sessionStore.isLoggedIn
                    ? "Usuário autenticado"
                    : "Usuário não autenticado"
            )
            .font(.title)

            Button(
                sessionStore.isLoggedIn
                    ? "Sair"
                    : "Entrar"
            ) {
                if sessionStore.isLoggedIn {
                    sessionStore.logout()
                } else {
                    sessionStore.login()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

#Preview {
    SessionStateView()
        .environment(SessionStore())
        .padding(AppSpacing.large)
}

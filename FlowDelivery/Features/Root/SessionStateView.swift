import SwiftUI

struct SessionStateView: View {
    @Binding
    var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Text(isLoggedIn ? "Home" : "Login")
                .font(.title)

            Button("Alternar estado") {
                isLoggedIn.toggle()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

#Preview {
    @Previewable @State var isLoggedIn = false

    SessionStateView(isLoggedIn: $isLoggedIn)
        .padding(AppSpacing.large)
}

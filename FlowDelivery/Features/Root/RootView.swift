import SwiftUI

struct RootView: View {

    @State
    private var isLoggedIn = false

    var body: some View {

        NavigationStack {

            VStack(spacing: 24) {

                Text(isLoggedIn ? "Home" : "Login")

                Button("Alternar estado") {

                    isLoggedIn.toggle()

                }
                .buttonStyle(PrimaryButtonStyle())

            }
            .padding(24)
            .navigationTitle("FlowDelivery")

        }

    }

}

#Preview {
    RootView()
}

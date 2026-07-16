import SwiftUI

struct RootView: View {
    @State
    private var isLoggedIn = false

    var body: some View {
        NavigationStack {
            SessionStateView(isLoggedIn: $isLoggedIn)
                .padding(AppSpacing.large)
                .navigationTitle("FlowDelivery")
        }
    }
}

#Preview {
    RootView()
}

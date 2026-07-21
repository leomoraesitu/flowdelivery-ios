import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            SessionStateView()
                .padding(AppSpacing.large)
                .navigationTitle("FlowDelivery")
        }
    }
}

#Preview {
    RootView()
        .environment(SessionStore())
}

import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self)
    private var sessionStore

    private var viewModel: RootViewModel {
        RootViewModel(sessionStore: sessionStore)
    }

    var body: some View {
        NavigationStack {
            SessionStateView(
                viewModel: viewModel
            )
            .padding(AppSpacing.large)
            .navigationTitle("FlowDelivery")
        }
    }
}

#Preview {
    RootView()
        .environment(SessionStore())
}

import SwiftUI

struct RootView: View {
    let viewModel: RootViewModel

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
    RootView(
        viewModel: AppContainer().rootViewModel
    )
}

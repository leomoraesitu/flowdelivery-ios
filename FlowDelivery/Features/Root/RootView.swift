import SwiftUI

struct RootView: View {
    let viewModel: RootViewModel

    var body: some View {
        NavigationStack {
            content
                .padding(AppSpacing.large)
                .navigationTitle("FlowDelivery")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.rootState {
        case .loading:
            ProgressView()

        case .authenticated:
            ContentView()

        case .unauthenticated:
            SessionStateView(
                viewModel: viewModel
            )
        }
    }
}

#Preview {
    RootView(
        viewModel: AppContainer().rootViewModel
    )
}

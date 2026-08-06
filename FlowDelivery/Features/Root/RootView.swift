import SwiftUI

struct RootView: View {
    let viewModel: RootViewModel
    let homeViewModel: HomeViewModel
    let appContainer: AppContainer

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
        case .authenticated:
            HomeView(
                viewModel: homeViewModel,
                appContainer: appContainer
            )

        case .unauthenticated:
            AuthenticationView(
                viewModel: viewModel.authenticationViewModel
            )
        }
    }
}

#Preview {
    let container = AppContainer()

    RootView(
        viewModel: container.rootViewModel,
        homeViewModel: container.homeViewModel,
        appContainer: container
    )
}

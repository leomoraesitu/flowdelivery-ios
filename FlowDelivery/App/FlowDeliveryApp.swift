import SwiftUI

@main
struct FlowDeliveryApp: App {
    @State
    private var container: AppContainer

    @State
    private var startupViewModel: AppStartupViewModel

    init() {
        let container = AppContainer()

        _container = State(
            initialValue: container
        )

        _startupViewModel = State(
            initialValue: AppStartupViewModel(
                container: container
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                viewModel: container.rootViewModel,
                homeViewModel: container.homeViewModel,
                appContainer: container
            )
            .environment(container)
            .environment(container.sessionStore)
            .task {
                startupViewModel.start()
            }
        }
    }
}

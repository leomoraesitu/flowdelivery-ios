import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()

            case .loaded:
                Text("Home")
            }
        }
        .padding()
        .task {
            viewModel.load()
        }
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel()
    )
}

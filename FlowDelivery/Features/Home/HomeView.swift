import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()

            case let .loaded(restaurants):
                List(restaurants) { restaurant in
                    Text(restaurant.name)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(repository: FakeRestaurantRepository())
    )
}

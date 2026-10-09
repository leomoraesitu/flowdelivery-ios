import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel
    let appContainer: AppContainer
    @State private var isConfirmingSignOut = false

    private var cartAccessibilityValue: String {
        let itemCount = appContainer.cartStore.itemCount

        switch itemCount {
        case 0:
            return "Vazio"

        case 1:
            return "1 item"

        default:
            return "\(itemCount) itens"
        }
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()

            case let .loaded(content):
                List(content.restaurants) { restaurant in
                    NavigationLink(
                        value: AppRoute.restaurantDetails(
                            restaurant.id
                        )
                    ) {
                        RestaurantRowView(
                            model: restaurant
                        )
                    }
                }
                .refreshable {
                    await viewModel.load()
                }

            case let .error(error):
                ContentUnavailableView {
                    Label(
                        error.message,
                        systemImage: "wifi.exclamationmark"
                    )
                } actions: {
                    Button("Tentar novamente") {
                        Task {
                            await viewModel.load()
                        }
                    }
                }

            case .empty:
                ContentUnavailableView(
                    "Nenhum restaurante encontrado",
                    systemImage: "fork.knife.circle"
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("Sair", role: .destructive) {
                        isConfirmingSignOut = true
                    }
                } label: {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Conta")
            }
            ToolbarItemGroup(
                placement: .topBarTrailing
            ) {
                NavigationLink(
                    value: AppRoute.orderHistory
                ) {
                    Image(
                        systemName: "clock.arrow.circlepath"
                    )
                }
                .accessibilityLabel("Meus pedidos")

                NavigationLink(
                    value: AppRoute.cart
                ) {
                    CartBadgeView(
                        itemCount: appContainer.cartStore.itemCount
                    )
                }
                .accessibilityLabel("Carrinho")
                .accessibilityValue(
                    Text(cartAccessibilityValue)
                )
            }
        }
        .confirmationDialog(
            "Sair da conta?",
            isPresented: $isConfirmingSignOut,
            titleVisibility: .visible
        ) {
            Button("Sair da conta", role: .destructive) {
                appContainer.rootViewModel.signOut()
            }

            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Seu carrinho será esvaziado.")
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}

extension HomeViewModel.HomeError {
    var message: LocalizedStringKey {
        switch self {
        case .loadFailed:
            "Não foi possível carregar os restaurantes."
        }
    }
}

#Preview {
    let container = AppContainer(credentialStore: FakeSessionCredentialStore())
    HomeView(
        viewModel: HomeViewModel(
            repository: FakeRestaurantRepository()
        ),
        appContainer: container
    )
}

#Preview("Empty") {
    let container = AppContainer(credentialStore: FakeSessionCredentialStore())
    let viewModel = HomeViewModel(
        repository: EmptyRestaurantRepository()
    )

    HomeView(
        viewModel: viewModel,
        appContainer: container
    )
}

#Preview("Error") {
    let container = AppContainer(credentialStore: FakeSessionCredentialStore())
    let viewModel = HomeViewModel(
        repository: FailingRestaurantRepository()
    )

    HomeView(
        viewModel: viewModel,
        appContainer: container
    )
}

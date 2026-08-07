import SwiftUI

struct CartView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                "Carrinho",
                systemImage: "cart"
            )
        } description: {
            Text(
                "Os itens adicionados serão exibidos aqui."
            )
        }
        .navigationTitle("Carrinho")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CartView()
    }
}

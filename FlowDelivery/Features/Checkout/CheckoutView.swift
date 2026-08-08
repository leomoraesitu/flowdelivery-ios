import SwiftUI

struct CheckoutView: View {
    var body: some View {
        ContentUnavailableView(
            "Checkout",
            systemImage: "creditcard",
            description: Text(
                "O resumo do pedido será adicionado na próxima aula."
            )
        )
        .navigationTitle("Finalizar pedido")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
    }
}

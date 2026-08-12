import SwiftUI

struct OrderSuccessView<ContinueAction: View>: View {
    @ViewBuilder
    let continueAction: () -> ContinueAction

    var body: some View {
        ContentUnavailableView {
            Label(
                "Pedido realizado!",
                systemImage: "checkmark.circle.fill"
            )
        } description: {
            Text(
                "Seu pedido foi confirmado e já está sendo preparado."
            )
        } actions: {
            continueAction()
        }
        .padding(AppSpacing.large)
    }
}

#Preview {
    OrderSuccessView {
        Button("Continuar") {}
            .buttonStyle(PrimaryButtonStyle())
    }
}

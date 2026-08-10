import SwiftUI

struct OrderSuccessView: View {
    let onContinue: () -> Void

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
            Button(
                "Continuar",
                action: onContinue
            )
            .buttonStyle(
                PrimaryButtonStyle()
            )
        }
        .padding(AppSpacing.large)
    }
}

#Preview {
    OrderSuccessView(
        onContinue: {}
    )
}

import SwiftUI

struct CartQuantityControlView: View {
    let quantity: Int
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Button(
                action: onDecrement
            ) {
                Label(
                    "Diminuir quantidade",
                    systemImage: "minus.circle.fill"
                )
                .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            .disabled(quantity <= 1)

            Text(
                quantity,
                format: .number
            )
            .font(AppTypography.bodyBold)
            .monospacedDigit()

            Button(
                action: onIncrement
            ) {
                Label(
                    "Aumentar quantidade",
                    systemImage: "plus.circle.fill"
                )
                .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
        }
    }
}

#Preview("Minimum quantity") {
    CartQuantityControlView(
        quantity: 1,
        onDecrement: {},
        onIncrement: {}
    )
    .padding()
}

#Preview("Multiple items") {
    CartQuantityControlView(
        quantity: 3,
        onDecrement: {},
        onIncrement: {}
    )
    .padding()
}

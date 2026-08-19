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
            .frame(
                minWidth: AppComponentSize.minimumHitTarget,
                minHeight: AppComponentSize.minimumHitTarget
            )
            .contentShape(Rectangle())
            .accessibilityValue("\(quantity)")
            .disabled(quantity <= 1)

            Text(
                quantity,
                format: .number
            )
            .font(AppTypography.bodyBold)
            .monospacedDigit()
            .accessibilityHidden(true)

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
            .frame(
                minWidth: AppComponentSize.minimumHitTarget,
                minHeight: AppComponentSize.minimumHitTarget
            )
            .contentShape(Rectangle())
            .accessibilityValue("\(quantity)")
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

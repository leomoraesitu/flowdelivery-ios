import SwiftUI

struct CartSummaryView<CheckoutAction: View>: View {
    let total: String

    @ViewBuilder
    let checkoutAction: () -> CheckoutAction

    var body: some View {
        VStack(
            spacing: AppSpacing.large
        ) {
            HStack(
                alignment: .firstTextBaseline,
                spacing: AppSpacing.medium
            ) {
                Text("Total")
                    .font(AppTypography.bodyBold)

                Spacer()

                Text(total)
                    .font(AppTypography.headline)
                    .monospacedDigit()
            }
            .accessibilityElement(
                children: .combine
            )
            .accessibilityIdentifier(
                "CartSummary.Total"
            )

            checkoutAction()
        }
        .padding(AppSpacing.large)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .overlay(
            alignment: .top
        ) {
            Divider()
        }
    }
}

#Preview {
    CartSummaryView(
        total: "R$ 154,70"
    ) {
        Button("Finalizar pedido") {}
            .buttonStyle(PrimaryButtonStyle())
    }
}

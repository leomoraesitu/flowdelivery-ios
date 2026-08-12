import SwiftUI

struct CartSummaryView: View {
    let total: String

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

            NavigationLink(
                value: AppRoute.checkout
            ) {
                Text("Finalizar pedido")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
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
    )
}

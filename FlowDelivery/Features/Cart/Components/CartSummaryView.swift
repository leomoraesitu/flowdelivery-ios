import SwiftUI

struct CartSummaryView: View {
    let total: String

    var body: some View {
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
        .padding(AppSpacing.large)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .overlay(
            alignment: .top
        ) {
            Divider()
        }
        .accessibilityElement(
            children: .combine
        )
    }
}

#Preview {
    CartSummaryView(
        total: "R$ 154,70"
    )
}

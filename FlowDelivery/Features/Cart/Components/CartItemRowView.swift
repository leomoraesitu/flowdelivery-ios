import SwiftUI

struct CartItemRowView: View {
    let content: CartItemContent

    var body: some View {
        HStack(
            alignment: .top,
            spacing: AppSpacing.medium
        ) {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.small
            ) {
                Text(content.title)
                    .font(AppTypography.headline)

                Text(content.unitPrice)
                    .font(AppTypography.body)
                    .foregroundStyle(.secondary)

                Text("Quantidade: \(content.quantity)")
                    .font(AppTypography.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: AppSpacing.xxSmall
            ) {
                Text("Subtotal")
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)

                Text(content.subtotal)
                    .font(AppTypography.bodyBold)
            }
        }
        .padding(.vertical, AppSpacing.small)
    }
}

#Preview {
    CartItemRowView(
        content: CartItemContent(
            id: UUID(),
            title: "Pizza Margherita",
            unitPrice: "R$ 49,90",
            quantity: 2,
            subtotal: "R$ 99,80"
        )
    )
    .padding()
}

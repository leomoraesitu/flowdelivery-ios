import SwiftUI

struct CartItemRowView: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    let content: CartItemContent
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        Group {
            if dynamicTypeSize > .large {
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.small
                ) {
                    itemInformation

                    subtotalInformation
                        .frame(
                            maxWidth: .infinity,
                            alignment: .trailing
                        )
                }
            } else {
                HStack(
                    alignment: .top,
                    spacing: AppSpacing.medium
                ) {
                    itemInformation

                    Spacer()

                    subtotalInformation
                }
            }
        }
        .padding(.vertical, AppSpacing.small)
    }

    private var itemInformation: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {
            Text(content.title)
                .font(AppTypography.headline)

            Text(content.unitPrice)
                .font(AppTypography.body)
                .foregroundStyle(.primary)

            CartQuantityControlView(
                quantity: content.quantity,
                onDecrement: onDecrement,
                onIncrement: onIncrement
            )
        }
    }

    private var subtotalInformation: some View {
        VStack(
            alignment: .trailing,
            spacing: AppSpacing.xxSmall
        ) {
            Text("Subtotal")
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.primary)
                .accessibilityHidden(true)

            Text(content.subtotal)
                .font(AppTypography.bodyBold)
                .accessibilityLabel(
                    "Subtotal, \(content.subtotal)"
                )
                .accessibilityIdentifier(
                    "CartItem.Subtotal"
                )
        }
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
        ),
        onDecrement: {},
        onIncrement: {}
    )
    .padding()
}

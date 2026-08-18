import SwiftUI

struct OrderHistoryRowView: View {
    let entry: OrderHistoryEntry

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {
            Text(entry.date)
                .font(AppTypography.headline)

            HStack {
                Label(
                    entry.itemCount,
                    systemImage: "bag"
                )

                Spacer()

                Text(entry.total)
                    .font(AppTypography.bodyBold)
                    .monospacedDigit()
            }
            .font(AppTypography.caption)
            .foregroundStyle(.secondary)
        }
        .padding(
            .vertical,
            AppSpacing.xSmall
        )
        .accessibilityElement(
            children: .combine
        )
    }
}

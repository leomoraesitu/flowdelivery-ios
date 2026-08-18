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

#Preview {
    List {
        OrderHistoryRowView(
            entry: OrderHistoryEntry(
                id: UUID(),
                date: "18 de ago. de 2026, 14:32",
                itemCount: "2 itens",
                total: "R$ 99,80"
            )
        )
    }
    .listStyle(.plain)
}

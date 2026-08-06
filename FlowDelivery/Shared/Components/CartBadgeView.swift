import SwiftUI

struct CartBadgeView: View {
    let itemCount: Int

    var body: some View {
        HStack(spacing: AppSpacing.xSmall) {
            Image(systemName: "cart")

            if itemCount > 0 {
                Text("\(itemCount)")
                    .font(AppTypography.caption)
                    .padding(.horizontal, AppSpacing.xSmall)
                    .padding(.vertical, AppSpacing.xxSmall)
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview("Empty") {
    CartBadgeView(
        itemCount: 0
    )
}

#Preview("With items") {
    CartBadgeView(
        itemCount: 3
    )
}

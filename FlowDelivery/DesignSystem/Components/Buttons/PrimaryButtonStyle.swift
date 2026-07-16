import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    private let pressedOpacity = 0.8
    private let pressedScale = 0.98

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.button)
            .foregroundStyle(AppColor.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppSize.primaryButtonHeight)
            .padding(.horizontal, AppSpacing.medium)
            .background(AppColor.primary)
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.medium)
            )
            .opacity(configuration.isPressed ? pressedOpacity : 1)
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(
                .easeOut(duration: AppDuration.extraSmall),
                value: configuration.isPressed
            )
    }
}

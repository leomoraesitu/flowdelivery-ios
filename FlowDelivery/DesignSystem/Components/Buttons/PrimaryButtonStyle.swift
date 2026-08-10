import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled)
    private var isEnabled
    private let pressedOpacity = 0.8
    private let pressedScale = 0.98
    private let disabledOpacity = 0.5

    private func opacity(
        for configuration: Configuration
    ) -> Double {
        guard isEnabled else {
            return disabledOpacity
        }

        return configuration.isPressed
            ? pressedOpacity
            : 1
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.button)
            .foregroundStyle(AppColor.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppComponentSize.primaryButtonHeight)
            .padding(.horizontal, AppSpacing.medium)
            .background(AppColor.primary)
            .clipShape(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
            )
            .opacity(
                opacity(
                    for: configuration
                )
            )
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(
                .easeOut(duration: AppDuration.extraSmall),
                value: configuration.isPressed
            )
    }
}

#Preview("States") {
    VStack(
        spacing: AppSpacing.large
    ) {
        Button("Habilitado") {}
            .buttonStyle(
                PrimaryButtonStyle()
            )

        Button("Desabilitado") {}
            .buttonStyle(
                PrimaryButtonStyle()
            )
            .disabled(true)
    }
    .padding(AppSpacing.large)
}

import SwiftUI

struct MenuItemRowView: View {
    let content: MenuItemContent

    var body: some View {
        HStack(
            spacing: AppSpacing.medium
        ) {
            AsyncImage(
                url: content.imageURL
            ) { phase in
                switch phase {
                case .empty:
                    ProgressView()

                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(AppSpacing.small)

                @unknown default:
                    EmptyView()
                }
            }
            .frame(
                width: AppComponentSize.menuItemImage,
                height: AppComponentSize.menuItemImage
            )
            .background(.quaternary)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.medium
                )
            )

            VStack(
                alignment: .leading,
                spacing: AppSpacing.small
            ) {
                Text(content.title)
                    .font(AppTypography.headline)

                Text(content.description)
                    .font(AppTypography.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text(content.price)
                    .font(AppTypography.bodyBold)
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.small)
    }
}

#Preview {
    MenuItemRowView(
        content: MenuItemContent(
            menuItem: MenuItem(
                id: UUID(),
                name: "Pizza Margherita",
                description: "Molho de tomate, mussarela e manjericão.",
                price: Decimal(string: "49.90")!,
                imageURL: URL(string: "https://picsum.photos/120")
            )
        )
    )
}

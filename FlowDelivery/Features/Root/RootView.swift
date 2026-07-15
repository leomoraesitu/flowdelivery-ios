import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("FlowDelivery")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button("Começar") {
                print("Primary button tapped")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(24)
    }
}

#Preview {
    RootView()
}

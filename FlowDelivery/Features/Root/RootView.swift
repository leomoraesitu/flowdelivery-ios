import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("FlowDelivery")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button("Começar") {
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(24)
            .navigationTitle("FlowDelivery")
        }
    }
}

#Preview {
    RootView()
}

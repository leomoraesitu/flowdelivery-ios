import SwiftUI

struct RestaurantDetailsView: View {
    var body: some View {
        Text("Restaurant Details")
            .navigationTitle("Restaurant")
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailsView()
    }
}

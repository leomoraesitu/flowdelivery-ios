import SwiftUI

struct RestaurantDetailsView: View {
    let restaurantID: UUID

    var body: some View {
        Text(restaurantID.uuidString)
            .navigationTitle("Restaurant")
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailsView(
            restaurantID: UUID()
        )
    }
}

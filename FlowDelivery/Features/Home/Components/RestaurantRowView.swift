import SwiftUI

struct RestaurantRowView: View {
    let restaurant: Restaurant

    var body: some View {
        Text(restaurant.name)
    }
}

#Preview {
    RestaurantRowView(
        restaurant: Restaurant(
            id: UUID(),
            name: "Pizzaria Itália"
        )
    )
}

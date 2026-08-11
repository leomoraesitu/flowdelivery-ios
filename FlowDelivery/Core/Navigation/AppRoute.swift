import Foundation

enum AppRoute: Hashable {
    case orderHistory
    case orderDetails(UUID)
    case restaurantDetails(UUID)
    case cart
}

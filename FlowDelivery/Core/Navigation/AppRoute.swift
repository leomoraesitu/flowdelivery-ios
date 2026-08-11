import Foundation

enum AppRoute: Hashable {
    case orderHistory
    case orderDetails(UUID)
}

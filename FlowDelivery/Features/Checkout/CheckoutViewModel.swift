import Foundation
import Observation

@MainActor
@Observable
final class CheckoutViewModel {
    private let cartStore: CartStore
    private let orderRepository: OrderRepository

    var deliveryAddress = ""
    var paymentMethod: PaymentMethod?

    private(set) var orderCreationError: OrderCreationError?

    var isOrderCreationErrorPresented: Bool {
        get {
            orderCreationError != nil
        }
        set {
            if !newValue {
                orderCreationError = nil
            }
        }
    }

    var canConfirmOrder: Bool {
        let normalizedAddress = deliveryAddress.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return !normalizedAddress.isEmpty &&
            paymentMethod != nil &&
            cartStore.itemCount > 0
    }

    enum CheckoutState: Equatable {
        case empty
        case loaded(CheckoutContent)
    }

    enum OrderCreationError: Equatable {
        case failed

        var message: String {
            switch self {
            case .failed:
                "Não foi possível concluir o pedido. Tente novamente."
            }
        }
    }

    init(
        cartStore: CartStore,
        orderRepository: OrderRepository
    ) {
        self.cartStore = cartStore
        self.orderRepository = orderRepository
    }

    var state: CheckoutState {
        guard cartStore.itemCount > 0 else {
            return .empty
        }

        return .loaded(
            CheckoutContent(
                itemCount: cartStore.itemCount,
                total: cartStore.total
            )
        )
    }

    func confirmOrder() async -> Bool {
        orderCreationError = nil

        guard canConfirmOrder,
              let selectedPaymentMethod = paymentMethod
        else {
            return false
        }

        let normalizedAddress = deliveryAddress.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let order = Order(
            id: UUID(),
            items: cartStore.items,
            deliveryAddress: normalizedAddress,
            paymentMethod: selectedPaymentMethod,
            createdAt: .now
        )

        do {
            try await orderRepository.createOrder(
                order
            )
        } catch {
            orderCreationError = .failed

            return false
        }

        cartStore.clear()

        deliveryAddress = ""
        paymentMethod = nil

        return true
    }
}

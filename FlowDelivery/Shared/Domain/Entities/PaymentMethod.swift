enum PaymentMethod: CaseIterable, Identifiable, Equatable, Sendable {
    case creditCard
    case pix
    case cash

    var id: Self {
        self
    }
}

enum PaymentMethod: CaseIterable, Identifiable, Equatable {
    case creditCard
    case pix
    case cash

    var id: Self {
        self
    }
}

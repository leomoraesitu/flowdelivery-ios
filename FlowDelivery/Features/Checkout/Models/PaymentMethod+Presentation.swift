extension PaymentMethod {
    var title: String {
        switch self {
        case .creditCard:
            "Cartão de crédito"

        case .pix:
            "Pix"

        case .cash:
            "Dinheiro"
        }
    }

    var systemImage: String {
        switch self {
        case .creditCard:
            "creditcard"

        case .pix:
            "qrcode"

        case .cash:
            "banknote"
        }
    }
}

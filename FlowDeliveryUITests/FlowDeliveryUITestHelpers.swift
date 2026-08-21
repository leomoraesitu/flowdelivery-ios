import XCTest

enum UITestLaunchArgument {
    static let inMemoryTokenStore =
        "-ui-testing-in-memory-token-store"
}

enum UITestTimeout {
    static let standard: TimeInterval = 15
}

extension XCTestCase {
    @MainActor
    func launchApp(
        launchArguments: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()

        app.launchArguments = launchArguments + [
            UITestLaunchArgument.inMemoryTokenStore
        ]

        app.launch()

        return app
    }

    @MainActor
    func makeHomeApp(
        launchArguments: [String] = []
    ) -> XCUIApplication {
        let app = launchApp(
            launchArguments: launchArguments
        )

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        loginButton.tap()

        XCTAssertTrue(
            app.navigationBars["FlowDelivery"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        return app
    }

    @MainActor
    func makeCartApp(
        menuItemNames: [String] = [
            "Pizza Margherita"
        ],
        launchArguments: [String] = []
    ) -> XCUIApplication {
        let app = makeHomeApp(
            launchArguments: launchArguments
        )

        let restaurant = app.staticTexts["Pizzaria Itália"]
        XCTAssertTrue(restaurant.waitForExistence(timeout: UITestTimeout.standard))
        restaurant.tap()

        for menuItemName in menuItemNames {
            let addButton = app.buttons[
                "Adicionar \(menuItemName)"
            ]
            XCTAssertTrue(
                addButton.waitForExistence(timeout: UITestTimeout.standard)
            )
            addButton.tap()
        }

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(backButton.waitForExistence(timeout: UITestTimeout.standard))
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(cartButton.waitForExistence(timeout: UITestTimeout.standard))
        cartButton.tap()

        XCTAssertTrue(
            app.navigationBars["Carrinho"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        return app
    }

    @MainActor
    func makeCheckoutApp(
        launchArguments: [String] = []
    ) -> XCUIApplication {
        let app = makeCartApp(
            launchArguments: launchArguments
        )
        configureCheckout(in: app)

        return app
    }

    @MainActor
    func configureCheckout(
        in app: XCUIApplication
    ) {
        let checkoutButton = app.buttons["Finalizar pedido"]
        XCTAssertTrue(
            checkoutButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        checkoutButton.tap()

        let addressField = app.textFields[
            "Rua, número e complemento"
        ]
        XCTAssertTrue(
            addressField.waitForExistence(timeout: UITestTimeout.standard)
        )
        addressField.tap()
        addressField.typeText("Avenida Paulista, 1000")
        app.keyboards.buttons["Return"].tap()

        let paymentPicker = app.buttons[
            "Forma de pagamento, Selecione"
        ]
        XCTAssertTrue(
            paymentPicker.waitForExistence(timeout: UITestTimeout.standard)
        )
        paymentPicker.tap()

        let pixOption = app.buttons["Pix"]
        XCTAssertTrue(
            pixOption.waitForExistence(timeout: UITestTimeout.standard)
        )
        pixOption.tap()
    }

    @MainActor
    func confirmOrder(in app: XCUIApplication) {
        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: UITestTimeout.standard))
        confirmButton.tap()

        let placeOrderButton = app.buttons["Fazer pedido"]
        XCTAssertTrue(placeOrderButton.waitForExistence(timeout: UITestTimeout.standard))
        placeOrderButton.tap()
    }

    @MainActor
    func makeOrderHistoryApp(
        launchArguments: [String] = []
    ) -> XCUIApplication {
        let app = makeHomeApp(
            launchArguments: launchArguments
        )

        let historyButton = app.buttons["Meus pedidos"]
        XCTAssertTrue(
            historyButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        historyButton.tap()

        XCTAssertTrue(
            app.navigationBars["Meus pedidos"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        return app
    }

    @MainActor
    func orderHistoryRows(
        in app: XCUIApplication
    ) -> XCUIElementQuery {
        app.descendants(
            matching: .any
        ).matching(
            NSPredicate(
                format: "identifier BEGINSWITH %@",
                "OrderHistory.Row."
            )
        )
    }

    /// Descarta um diálogo apresentado como popover.
    ///
    /// Nesse modo de apresentação o sistema não exibe a ação com
    /// `role: .cancel` — o descarte acontece ao tocar fora do diálogo.
    @MainActor
    func dismissPopoverDialog(in app: XCUIApplication) {
        let dismissRegion = app.otherElements["PopoverDismissRegion"]

        if dismissRegion.waitForExistence(timeout: 1) {
            dismissRegion.tap()
            return
        }

        app.coordinate(
            withNormalizedOffset: CGVector(
                dx: 0.5,
                dy: 0.05
            )
        ).tap()
    }
}

import Foundation

extension String {
    /// Remove caracteres invisíveis que o sistema insere em textos acessíveis.
    ///
    /// Formatadores de moeda usam espaços não separáveis entre o símbolo e o
    /// valor, e chaves localizadas com interpolação envolvem o argumento em
    /// marcas de isolamento bidirecional. Ambos são invisíveis e quebram
    /// comparações literais em testes.
    var normalizingSpaces: String {
        let bidiIsolates: Set<Unicode.Scalar> = [
            "\u{2066}",
            "\u{2067}",
            "\u{2068}",
            "\u{2069}"
        ]

        let withoutIsolates = String(
            String.UnicodeScalarView(
                unicodeScalars.filter { !bidiIsolates.contains($0) }
            )
        )

        return withoutIsolates
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\u{202F}", with: " ")
    }
}

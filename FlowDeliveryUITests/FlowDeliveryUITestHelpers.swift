import XCTest

extension FlowDeliveryUITests {
    @MainActor
    func makeCartApp(
        menuItemNames: [String] = [
            "Pizza Margherita"
        ],
        launchArguments: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = launchArguments
        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        let restaurant = app.staticTexts["Pizzaria Itália"]
        XCTAssertTrue(restaurant.waitForExistence(timeout: 5))
        restaurant.tap()

        for menuItemName in menuItemNames {
            let addButton = app.buttons[
                "Adicionar \(menuItemName)"
            ]
            XCTAssertTrue(
                addButton.waitForExistence(timeout: 5)
            )
            addButton.tap()
        }

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(cartButton.waitForExistence(timeout: 5))
        cartButton.tap()

        XCTAssertTrue(
            app.navigationBars["Carrinho"].waitForExistence(
                timeout: 5
            )
        )

        return app
    }

    @MainActor
    func makeCheckoutApp() -> XCUIApplication {
        let app = makeCartApp()
        configureCheckout(in: app)

        return app
    }

    @MainActor
    func configureCheckout(
        in app: XCUIApplication
    ) {
        let checkoutButton = app.buttons["Finalizar pedido"]
        XCTAssertTrue(
            checkoutButton.waitForExistence(timeout: 5)
        )
        checkoutButton.tap()

        let addressField = app.textFields[
            "Rua, número e complemento"
        ]
        XCTAssertTrue(
            addressField.waitForExistence(timeout: 5)
        )
        addressField.tap()
        addressField.typeText("Avenida Paulista, 1000")
        app.keyboards.buttons["Return"].tap()

        let paymentPicker = app.buttons[
            "Forma de pagamento, Selecione"
        ]
        XCTAssertTrue(
            paymentPicker.waitForExistence(timeout: 5)
        )
        paymentPicker.tap()

        let pixOption = app.buttons["Pix"]
        XCTAssertTrue(
            pixOption.waitForExistence(timeout: 5)
        )
        pixOption.tap()
    }

    @MainActor
    func confirmOrder(in app: XCUIApplication) {
        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()

        let placeOrderButton = app.buttons["Fazer pedido"]
        XCTAssertTrue(placeOrderButton.waitForExistence(timeout: 5))
        placeOrderButton.tap()
    }
}

import XCTest

final class FlowDeliveryUITests: XCTestCase {
    @MainActor
    func testHomeScreenLoadsRestaurants() {
        let app = XCUIApplication()
        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        XCTAssertTrue(
            app.navigationBars["FlowDelivery"].waitForExistence(timeout: 5)
        )
        XCTAssertTrue(
            app.staticTexts["Pizzaria Itália"].waitForExistence(timeout: 5)
        )
    }

    @MainActor
    func testUserCanAddRestaurantItemToCart() {
        let app = XCUIApplication()
        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        let restaurant = app.staticTexts["Pizzaria Itália"]
        XCTAssertTrue(restaurant.waitForExistence(timeout: 5))
        restaurant.tap()

        let addButton = app.buttons["Adicionar Pizza Margherita"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(cartButton.waitForExistence(timeout: 5))
        XCTAssertEqual(
            cartButton.value as? String,
            "1 item"
        )
        cartButton.tap()

        XCTAssertTrue(
            app.navigationBars["Carrinho"].waitForExistence(timeout: 5)
        )
    }

    @MainActor
    func testUserCanCompleteOrder() {
        let app = makeCheckoutApp()
        confirmOrder(in: app)

        XCTAssertTrue(
            app.staticTexts["Pedido realizado!"].waitForExistence(timeout: 5)
        )
    }

    @MainActor
    func testUserCanNavigateToOrderHistoryAfterCompletingOrder() {
        let app = makeCheckoutApp()
        confirmOrder(in: app)

        let historyButton = app.buttons["Ver meus pedidos"]
        XCTAssertTrue(historyButton.waitForExistence(timeout: 5))
        historyButton.tap()

        XCTAssertTrue(
            app.navigationBars["Meus pedidos"].waitForExistence(timeout: 5)
        )
        XCTAssertTrue(app.staticTexts["1 item"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["R$ 49,90"].waitForExistence(timeout: 5)
        )
        app.staticTexts["1 item"].tap()

        XCTAssertTrue(
            app.navigationBars["Detalhes do pedido"].waitForExistence(
                timeout: 5
            )
        )
        let paymentMethod = app.descendants(
            matching: .any
        )["OrderDetails.PaymentMethod"]

        XCTAssertTrue(
            paymentMethod.waitForExistence(timeout: 5)
        )

        XCTAssertTrue(
            app.staticTexts["Pizza Margherita"].waitForExistence(
                timeout: 5
            )
        )

        let deliveryAddress = app.staticTexts[
            "OrderDetails.DeliveryAddress"
        ]

        XCTAssertTrue(
            deliveryAddress.waitForExistence(timeout: 5)
        )

        XCTAssertEqual(
            deliveryAddress.label,
            "Avenida Paulista, 1000"
        )

        let total = app.staticTexts[
            "OrderDetails.Total"
        ]

        XCTAssertTrue(
            total.waitForExistence(timeout: 5)
        )

        XCTAssertEqual(
            total.label,
            "Total, R$ 49,90"
        )
    }

    @MainActor
    private func makeCheckoutApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        let restaurant = app.staticTexts["Pizzaria Itália"]
        XCTAssertTrue(restaurant.waitForExistence(timeout: 5))
        restaurant.tap()

        let addButton = app.buttons["Adicionar Pizza Margherita"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        app.buttons["FlowDelivery"].tap()
        app.buttons["Carrinho"].tap()
        app.buttons["Finalizar pedido"].tap()

        let addressField = app.textFields["Rua, número e complemento"]
        XCTAssertTrue(addressField.waitForExistence(timeout: 5))
        addressField.tap()
        addressField.typeText("Avenida Paulista, 1000")
        app.keyboards.buttons["Return"].tap()

        let paymentPicker = app.buttons["Forma de pagamento, Selecione"]
        XCTAssertTrue(paymentPicker.waitForExistence(timeout: 5))
        paymentPicker.tap()

        let pixOption = app.buttons["Pix"]
        XCTAssertTrue(pixOption.waitForExistence(timeout: 5))
        pixOption.tap()

        return app
    }

    @MainActor
    private func confirmOrder(in app: XCUIApplication) {
        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()

        let placeOrderButton = app.buttons["Fazer pedido"]
        XCTAssertTrue(placeOrderButton.waitForExistence(timeout: 5))
        placeOrderButton.tap()
    }

    @MainActor
    func testUserCanSeeEmptyOrderHistory() {
        let app = XCUIApplication()

        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: 5)
        )
        loginButton.tap()

        let historyButton = app.buttons["Meus pedidos"]
        XCTAssertTrue(
            historyButton.waitForExistence(timeout: 5)
        )
        historyButton.tap()

        XCTAssertTrue(
            app.navigationBars["Meus pedidos"].waitForExistence(
                timeout: 5
            )
        )

        XCTAssertTrue(
            app.staticTexts["Nenhum pedido ainda"].waitForExistence(
                timeout: 5
            )
        )
    }

    @MainActor
    func testUserCanSeeEmptyCart() {
        let app = XCUIApplication()
        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: 5)
        )
        loginButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: 5)
        )
        cartButton.tap()

        XCTAssertTrue(
            app.navigationBars["Carrinho"].waitForExistence(
                timeout: 5
            )
        )

        XCTAssertTrue(
            app.staticTexts["Seu carrinho está vazio"].waitForExistence(
                timeout: 5
            )
        )
    }
}

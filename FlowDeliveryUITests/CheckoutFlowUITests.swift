import XCTest

extension FlowDeliveryUITests {
    @MainActor
    func testUserCanCompleteOrderWithRemainingCartItem() {
        let app = makeCartApp(
            menuItemNames: [
                "Pizza Margherita",
                "Pizza Calabresa"
            ]
        )

        let margherita = app.staticTexts["Pizza Margherita"]
        XCTAssertTrue(
            margherita.waitForExistence(timeout: 5)
        )

        margherita.swipeLeft()

        let removeButton = app.buttons["Remover"]
        XCTAssertTrue(
            removeButton.waitForExistence(timeout: 5)
        )
        removeButton.tap()

        XCTAssertTrue(
            margherita.waitForNonExistence(timeout: 5)
        )

        configureCheckout(in: app)
        confirmOrder(in: app)

        XCTAssertTrue(
            app.staticTexts["Pedido realizado!"].waitForExistence(
                timeout: 5
            )
        )

        let historyButton = app.buttons["Ver meus pedidos"]
        XCTAssertTrue(
            historyButton.waitForExistence(timeout: 5)
        )
        historyButton.tap()

        let orderEntry = app.staticTexts["1 item"]
        XCTAssertTrue(
            orderEntry.waitForExistence(timeout: 5)
        )
        orderEntry.tap()

        XCTAssertTrue(
            app.staticTexts["Pizza Calabresa"].waitForExistence(
                timeout: 5
            )
        )

        let total = app.staticTexts["OrderDetails.Total"]
        XCTAssertTrue(
            total.waitForExistence(timeout: 5)
        )

        XCTAssertEqual(
            total.label,
            "Total, R$ 54,90"
        )
    }

    @MainActor
    func testCartIsEmptyAfterCompletingOrder() {
        let app = makeCheckoutApp()

        confirmOrder(in: app)

        XCTAssertTrue(
            app.staticTexts["Pedido realizado!"].waitForExistence(
                timeout: 5
            )
        )

        let backButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5)
        )
        backButton.tap()

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

    @MainActor
    func testCartIsPreservedWhenOrderCreationFails() {
        let app = makeCartApp(
            launchArguments: [
                "-ui-testing-failing-order-repository"
            ]
        )

        configureCheckout(in: app)
        confirmOrder(in: app)

        let errorAlert = app.alerts[
            "Não foi possível fazer o pedido"
        ]
        XCTAssertTrue(
            errorAlert.waitForExistence(timeout: 5)
        )

        XCTAssertFalse(
            app.staticTexts["Pedido realizado!"].exists
        )

        let okButton = errorAlert.buttons["OK"]
        XCTAssertTrue(
            okButton.waitForExistence(timeout: 5)
        )
        okButton.tap()

        let backButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5)
        )
        backButton.tap()

        XCTAssertTrue(
            app.staticTexts["Pizza Margherita"].waitForExistence(
                timeout: 5
            )
        )
    }

    @MainActor
    func testUserCanRetryOrderAfterFailure() {
        let app = makeCartApp(
            launchArguments: [
                "-ui-testing-failing-order-repository"
            ]
        )

        configureCheckout(in: app)
        confirmOrder(in: app)

        let errorAlert = app.alerts[
            "Não foi possível fazer o pedido"
        ]
        XCTAssertTrue(
            errorAlert.waitForExistence(timeout: 5)
        )

        let okButton = errorAlert.buttons["OK"]
        XCTAssertTrue(
            okButton.waitForExistence(timeout: 5)
        )
        okButton.tap()

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 5)
        )
        XCTAssertTrue(confirmButton.isEnabled)

        confirmOrder(in: app)

        XCTAssertTrue(
            errorAlert.waitForExistence(timeout: 5)
        )
    }
}

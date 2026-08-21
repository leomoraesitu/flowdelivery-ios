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
            margherita.waitForExistence(timeout: UITestTimeout.standard)
        )

        margherita.swipeLeft()

        let removeButton = app.buttons["Remover"]
        XCTAssertTrue(
            removeButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        removeButton.tap()

        XCTAssertTrue(
            margherita.waitForNonExistence(timeout: UITestTimeout.standard)
        )

        configureCheckout(in: app)
        confirmOrder(in: app)

        XCTAssertTrue(
            app.staticTexts["Pedido realizado!"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        let historyButton = app.buttons["Ver meus pedidos"]
        XCTAssertTrue(
            historyButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        historyButton.tap()

        let orderEntry = app.staticTexts["1 item"]
        XCTAssertTrue(
            orderEntry.waitForExistence(timeout: UITestTimeout.standard)
        )
        orderEntry.tap()

        XCTAssertTrue(
            app.staticTexts["Pizza Calabresa"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        let total = app.staticTexts["OrderDetails.Total"]
        XCTAssertTrue(
            total.waitForExistence(timeout: UITestTimeout.standard)
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
                timeout: UITestTimeout.standard
            )
        )

        let backButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        backButton.tap()

        XCTAssertTrue(
            app.navigationBars["Carrinho"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        XCTAssertTrue(
            app.staticTexts["Seu carrinho está vazio"].waitForExistence(
                timeout: UITestTimeout.standard
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
            errorAlert.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertFalse(
            app.staticTexts["Pedido realizado!"].exists
        )

        let okButton = errorAlert.buttons["OK"]
        XCTAssertTrue(
            okButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        okButton.tap()

        let backButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        backButton.tap()

        XCTAssertTrue(
            app.staticTexts["Pizza Margherita"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )
    }

    @MainActor
    func testUserCanRetryOrderAfterFailure() {
        let app = makeCartApp(
            launchArguments: [
                "-ui-testing-fail-once-order-repository"
            ]
        )

        configureCheckout(in: app)
        confirmOrder(in: app)

        let errorAlert = app.alerts[
            "Não foi possível fazer o pedido"
        ]
        XCTAssertTrue(
            errorAlert.waitForExistence(timeout: UITestTimeout.standard)
        )

        let okButton = errorAlert.buttons["OK"]
        XCTAssertTrue(
            okButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        okButton.tap()

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertTrue(confirmButton.isEnabled)

        confirmOrder(in: app)

        XCTAssertTrue(
            app.staticTexts["Pedido realizado!"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )
        let historyButton = app.buttons["Ver meus pedidos"]
        XCTAssertTrue(
            historyButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        historyButton.tap()

        XCTAssertTrue(
            app.navigationBars["Meus pedidos"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        XCTAssertTrue(
            app.staticTexts["1 item"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        XCTAssertTrue(
            app.staticTexts["R$ 49,90"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )
    }

    @MainActor
    func testUserCanCancelOrderConfirmation() {
        let app = makeCheckoutApp()

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        confirmButton.tap()

        let confirmationAlert = app.alerts["Confirmar pedido?"]
        XCTAssertTrue(
            confirmationAlert.waitForExistence(timeout: UITestTimeout.standard)
        )

        let cancelButton = confirmationAlert.buttons["Cancelar"]
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        cancelButton.tap()

        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertTrue(confirmButton.isEnabled)

        XCTAssertFalse(
            app.staticTexts["Pedido realizado!"].exists
        )

        let backButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        backButton.tap()

        XCTAssertTrue(
            app.staticTexts["Pizza Margherita"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )
    }

    @MainActor
    func testUserCannotConfirmOrderWithoutDeliveryAddress() {
        let app = makeCartApp()

        let checkoutButton = app.buttons["Finalizar pedido"]
        XCTAssertTrue(
            checkoutButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        checkoutButton.tap()

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

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertFalse(confirmButton.isEnabled)

        XCTAssertFalse(
            app.alerts["Confirmar pedido?"].exists
        )
    }

    @MainActor
    func testUserCannotConfirmOrderWithoutPaymentMethod() {
        let app = makeCartApp()

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

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertFalse(confirmButton.isEnabled)

        XCTAssertFalse(
            app.alerts["Confirmar pedido?"].exists
        )
    }

    @MainActor
    func testUserCanConfirmOrderWhenCheckoutIsComplete() {
        let app = makeCartApp()

        let checkoutButton = app.buttons["Finalizar pedido"]
        XCTAssertTrue(
            checkoutButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        checkoutButton.tap()

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

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertFalse(confirmButton.isEnabled)

        let addressField = app.textFields[
            "Rua, número e complemento"
        ]
        addressField.tap()
        addressField.typeText("Avenida Paulista, 1000")
        app.keyboards.buttons["Return"].tap()

        XCTAssertTrue(
            confirmButton.wait(
                for: \.isEnabled,
                toEqual: true,
                timeout: UITestTimeout.standard
            )
        )
    }
}

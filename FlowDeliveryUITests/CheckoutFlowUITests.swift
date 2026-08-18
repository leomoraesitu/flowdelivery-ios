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
                "-ui-testing-fail-once-order-repository"
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
            app.staticTexts["Pedido realizado!"].waitForExistence(
                timeout: 5
            )
        )
        let historyButton = app.buttons["Ver meus pedidos"]
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
            app.staticTexts["1 item"].waitForExistence(
                timeout: 5
            )
        )

        XCTAssertTrue(
            app.staticTexts["R$ 49,90"].waitForExistence(
                timeout: 5
            )
        )
    }

    @MainActor
    func testUserCanCancelOrderConfirmation() {
        let app = makeCheckoutApp()

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 5)
        )
        confirmButton.tap()

        let confirmationAlert = app.alerts["Confirmar pedido?"]
        XCTAssertTrue(
            confirmationAlert.waitForExistence(timeout: 5)
        )

        let cancelButton = confirmationAlert.buttons["Cancelar"]
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: 5)
        )
        cancelButton.tap()

        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 5)
        )
        XCTAssertTrue(confirmButton.isEnabled)

        XCTAssertFalse(
            app.staticTexts["Pedido realizado!"].exists
        )

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
    func testUserCannotConfirmOrderWithoutDeliveryAddress() {
        let app = makeCartApp()

        let checkoutButton = app.buttons["Finalizar pedido"]
        XCTAssertTrue(
            checkoutButton.waitForExistence(timeout: 5)
        )
        checkoutButton.tap()

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

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 5)
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

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 5)
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
            checkoutButton.waitForExistence(timeout: 5)
        )
        checkoutButton.tap()

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

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 5)
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
                timeout: 5
            )
        )
    }
}

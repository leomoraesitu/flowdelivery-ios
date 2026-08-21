import XCTest

extension FlowDeliveryUITests {
    @MainActor
    func testUserCanAddRestaurantItemToCart() {
        let app = launchApp()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: UITestTimeout.standard))
        loginButton.tap()

        let restaurant = app.staticTexts["Pizzaria Itália"]
        XCTAssertTrue(restaurant.waitForExistence(timeout: UITestTimeout.standard))
        restaurant.tap()

        let addButton = app.buttons["Adicionar Pizza Margherita"]
        XCTAssertTrue(addButton.waitForExistence(timeout: UITestTimeout.standard))
        addButton.tap()

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(backButton.waitForExistence(timeout: UITestTimeout.standard))
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(cartButton.waitForExistence(timeout: UITestTimeout.standard))
        XCTAssertEqual(
            cartButton.value as? String,
            "1 item"
        )
        cartButton.tap()

        XCTAssertTrue(
            app.navigationBars["Carrinho"].waitForExistence(timeout: UITestTimeout.standard)
        )
    }

    @MainActor
    func testUserCanCompleteOrder() {
        let app = makeCheckoutApp()
        confirmOrder(in: app)

        XCTAssertTrue(
            app.staticTexts["Pedido realizado!"].waitForExistence(timeout: UITestTimeout.standard)
        )
    }

    @MainActor
    func testUserCanSeeEmptyCart() {
        let app = launchApp()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        loginButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        cartButton.tap()

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
    func testUserCanIncreaseCartItemQuantity() {
        let app = makeCartApp()

        let incrementButton = app.buttons["Aumentar quantidade"]
        XCTAssertTrue(
            incrementButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        incrementButton.tap()

        let quantity = app.staticTexts["2"]
        XCTAssertTrue(
            quantity.waitForExistence(timeout: UITestTimeout.standard)
        )

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertEqual(
            cartButton.value as? String,
            "2 itens"
        )
    }

    @MainActor
    func testUserCanDecreaseCartItemQuantity() {
        let app = makeCartApp()

        let incrementButton = app.buttons["Aumentar quantidade"]
        XCTAssertTrue(
            incrementButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        incrementButton.tap()

        let decrementButton = app.buttons["Diminuir quantidade"]
        XCTAssertTrue(
            decrementButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertTrue(decrementButton.isEnabled)
        decrementButton.tap()

        let quantity = app.staticTexts["1"]
        XCTAssertTrue(
            quantity.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertFalse(decrementButton.isEnabled)

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertEqual(
            cartButton.value as? String,
            "1 item"
        )
    }

    @MainActor
    func testCartUpdatesMonetaryValuesAfterIncrement() {
        let app = makeCartApp()

        let incrementButton = app.buttons[
            "Aumentar quantidade"
        ]
        XCTAssertTrue(
            incrementButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        incrementButton.tap()

        let subtotal = app.staticTexts[
            "CartItem.Subtotal"
        ]
        XCTAssertTrue(
            subtotal.waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertEqual(
            subtotal.label.normalizingSpaces,
            "Subtotal, R$ 99,80"
        )

        let total = app.descendants(
            matching: .any
        )["CartSummary.Total"]
        XCTAssertTrue(
            total.waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertEqual(
            total.label.normalizingSpaces,
            "Total, R$ 99,80"
        )
    }

    @MainActor
    func testUserCanClearCart() {
        let app = makeCartApp()

        let clearButton = app.navigationBars["Carrinho"]
            .buttons["Limpar carrinho"]
        XCTAssertTrue(
            clearButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        clearButton.tap()

        let dialog = app.sheets["Limpar carrinho?"]
        XCTAssertTrue(
            dialog.waitForExistence(timeout: UITestTimeout.standard)
        )

        let confirmClearButton = dialog.buttons["Limpar carrinho"]
        XCTAssertTrue(
            confirmClearButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        confirmClearButton.tap()

        XCTAssertTrue(
            app.staticTexts["Seu carrinho está vazio"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertEqual(
            cartButton.value as? String,
            "Vazio"
        )
    }

    @MainActor
    func testUserCanCancelCartClearing() {
        let app = makeCartApp()

        let clearButton = app.navigationBars["Carrinho"]
            .buttons["Limpar carrinho"]
        XCTAssertTrue(
            clearButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        clearButton.tap()

        let dialog = app.sheets["Limpar carrinho?"]
        XCTAssertTrue(
            dialog.waitForExistence(timeout: UITestTimeout.standard)
        )

        dismissPopoverDialog(in: app)

        XCTAssertTrue(
            dialog.waitForNonExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertTrue(
            app.staticTexts["Pizza Margherita"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )
    }

    @MainActor
    func testUserCanRemoveCartItem() {
        let app = makeCartApp()

        let cartItem = app.staticTexts["Pizza Margherita"]
        XCTAssertTrue(
            cartItem.waitForExistence(timeout: UITestTimeout.standard)
        )

        cartItem.swipeLeft()

        let removeButton = app.buttons["Remover"]
        XCTAssertTrue(
            removeButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        removeButton.tap()

        XCTAssertTrue(
            app.staticTexts["Seu carrinho está vazio"]
                .waitForExistence(timeout: UITestTimeout.standard)
        )
    }

    @MainActor
    func testUserCanRemoveOnlySelectedCartItem() {
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

        XCTAssertFalse(margherita.exists)

        XCTAssertTrue(
            app.staticTexts["Pizza Calabresa"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )
    }

    @MainActor
    func testCartItemPersistsAfterNavigatingAwayAndReturning() {
        let app = makeCartApp()

        let cartItem = app.staticTexts["Pizza Margherita"]
        XCTAssertTrue(
            cartItem.waitForExistence(timeout: UITestTimeout.standard)
        )

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        cartButton.tap()

        XCTAssertTrue(
            app.navigationBars["Carrinho"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        XCTAssertTrue(
            cartItem.waitForExistence(timeout: UITestTimeout.standard)
        )
    }

    @MainActor
    func testCartUpdatesTotalAfterRemovingItem() {
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

        let total = app.descendants(
            matching: .any
        )["CartSummary.Total"]

        XCTAssertTrue(
            total.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertEqual(
            total.label,
            "Total, R$ 54,90"
        )
    }

    @MainActor
    func testCartBadgeUpdatesAfterRemovingItem() {
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

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertEqual(
            cartButton.value as? String,
            "1 item"
        )
    }
}

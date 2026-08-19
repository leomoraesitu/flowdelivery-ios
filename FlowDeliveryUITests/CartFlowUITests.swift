import XCTest

extension FlowDeliveryUITests {
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

    @MainActor
    func testUserCanIncreaseCartItemQuantity() {
        let app = makeCartApp()

        let incrementButton = app.buttons["Aumentar quantidade"]
        XCTAssertTrue(
            incrementButton.waitForExistence(timeout: 5)
        )
        incrementButton.tap()

        let quantity = app.staticTexts["2"]
        XCTAssertTrue(
            quantity.waitForExistence(timeout: 5)
        )

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5)
        )
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: 5)
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
            incrementButton.waitForExistence(timeout: 5)
        )
        incrementButton.tap()

        let decrementButton = app.buttons["Diminuir quantidade"]
        XCTAssertTrue(
            decrementButton.waitForExistence(timeout: 5)
        )
        XCTAssertTrue(decrementButton.isEnabled)
        decrementButton.tap()

        let quantity = app.staticTexts["1"]
        XCTAssertTrue(
            quantity.waitForExistence(timeout: 5)
        )

        XCTAssertFalse(decrementButton.isEnabled)

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5)
        )
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: 5)
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
            incrementButton.waitForExistence(timeout: 5)
        )
        incrementButton.tap()

        let subtotal = app.staticTexts[
            "CartItem.Subtotal"
        ]
        XCTAssertTrue(
            subtotal.waitForExistence(timeout: 5)
        )
        XCTAssertEqual(
            subtotal.label,
            "R$ 99,80"
        )

        let total = app.descendants(
            matching: .any
        )["CartSummary.Total"]
        XCTAssertTrue(
            total.waitForExistence(timeout: 5)
        )
        XCTAssertEqual(
            total.label,
            "Total, R$ 99,80"
        )
    }

    @MainActor
    func testUserCanClearCart() {
        let app = makeCartApp()

        let clearButton = app.buttons["Limpar carrinho"]
        XCTAssertTrue(
            clearButton.waitForExistence(timeout: 5)
        )
        clearButton.tap()

        let confirmClearButton = app.buttons[
            "Limpar carrinho"
        ]
        XCTAssertTrue(
            confirmClearButton.waitForExistence(timeout: 5)
        )
        confirmClearButton.tap()

        XCTAssertTrue(
            app.staticTexts["Seu carrinho está vazio"].waitForExistence(
                timeout: 5
            )
        )

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5)
        )
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: 5)
        )

        XCTAssertEqual(
            cartButton.value as? String,
            "Vazio"
        )
    }

    @MainActor
    func testUserCanCancelCartClearing() {
        let app = makeCartApp()

        let clearButton = app.buttons["Limpar carrinho"]
        XCTAssertTrue(
            clearButton.waitForExistence(timeout: 5)
        )
        clearButton.tap()

        let confirmClearButton = app.buttons[
            "Limpar carrinho"
        ]
        XCTAssertTrue(
            confirmClearButton.waitForExistence(timeout: 5)
        )

        let cancelButton = app.buttons["Cancelar"]

        if cancelButton.waitForExistence(timeout: 1) {
            cancelButton.tap()
        } else {
            let outsideDialog = app.coordinate(
                withNormalizedOffset: CGVector(
                    dx: 0.5,
                    dy: 0.8
                )
            )
            outsideDialog.tap()
        }

        XCTAssertTrue(
            app.staticTexts["Pizza Margherita"].waitForExistence(
                timeout: 5
            )
        )

        XCTAssertFalse(
            confirmClearButton.exists
        )
    }

    @MainActor
    func testUserCanRemoveCartItem() {
        let app = makeCartApp()

        let cartItem = app.staticTexts["Pizza Margherita"]
        XCTAssertTrue(
            cartItem.waitForExistence(timeout: 5)
        )

        cartItem.swipeLeft()

        let removeButton = app.buttons["Remover"]
        XCTAssertTrue(
            removeButton.waitForExistence(timeout: 5)
        )
        removeButton.tap()

        XCTAssertTrue(
            app.staticTexts["Seu carrinho está vazio"]
                .waitForExistence(timeout: 5)
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
            margherita.waitForExistence(timeout: 5)
        )

        margherita.swipeLeft()

        let removeButton = app.buttons["Remover"]
        XCTAssertTrue(
            removeButton.waitForExistence(timeout: 5)
        )
        removeButton.tap()

        XCTAssertFalse(margherita.exists)

        XCTAssertTrue(
            app.staticTexts["Pizza Calabresa"].waitForExistence(
                timeout: 5
            )
        )
    }

    @MainActor
    func testCartItemPersistsAfterNavigatingAwayAndReturning() {
        let app = makeCartApp()

        let cartItem = app.staticTexts["Pizza Margherita"]
        XCTAssertTrue(
            cartItem.waitForExistence(timeout: 5)
        )

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5)
        )
        backButton.tap()

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
            cartItem.waitForExistence(timeout: 5)
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

        let total = app.descendants(
            matching: .any
        )["CartSummary.Total"]

        XCTAssertTrue(
            total.waitForExistence(timeout: 5)
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

        let backButton = app.buttons["FlowDelivery"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5)
        )
        backButton.tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: 5)
        )

        XCTAssertEqual(
            cartButton.value as? String,
            "1 item"
        )
    }
}

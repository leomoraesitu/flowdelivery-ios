import XCTest

final class FlowDeliveryUITests: XCTestCase {
    @MainActor
    func testHomeScreenLoadsRestaurants() {
        let app = XCUIApplication()

        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: 5)
        )
        loginButton.tap()

        XCTAssertTrue(
            app.navigationBars["FlowDelivery"].waitForExistence(
                timeout: 5
            )
        )

        XCTAssertTrue(
            app.staticTexts["Pizzaria Itália"].waitForExistence(
                timeout: 5
            )
        )
    }

    @MainActor
    func testUserCanAddRestaurantItemToCart() {
        let app = XCUIApplication()

        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: 5)
        )
        loginButton.tap()

        let restaurant = app.staticTexts["Pizzaria Itália"]
        XCTAssertTrue(
            restaurant.waitForExistence(timeout: 5)
        )
        restaurant.tap()

        let addButton = app.buttons["Adicionar Pizza Margherita"]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 5)
        )
        addButton.tap()

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
    }

    @MainActor
    func testUserCanCompleteOrder() {
        let app = XCUIApplication()

        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: 5)
        )
        loginButton.tap()

        let restaurant = app.staticTexts["Pizzaria Itália"]
        XCTAssertTrue(
            restaurant.waitForExistence(timeout: 5)
        )
        restaurant.tap()

        let addButton = app.buttons["Adicionar Pizza Margherita"]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 5)
        )
        addButton.tap()

        app.buttons["FlowDelivery"].tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: 5)
        )
        cartButton.tap()

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

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 5)
        )
        confirmButton.tap()

        let placeOrderButton = app.buttons["Fazer pedido"]
        XCTAssertTrue(
            placeOrderButton.waitForExistence(timeout: 5)
        )
        placeOrderButton.tap()

        XCTAssertTrue(
            app.staticTexts["Pedido realizado!"].waitForExistence(
                timeout: 5
            )
        )
    }

    @MainActor
    func testUserCanNavigateToOrderHistoryAfterCompletingOrder() {
        let app = XCUIApplication()

        app.launch()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: 5)
        )
        loginButton.tap()

        let restaurant = app.staticTexts["Pizzaria Itália"]
        XCTAssertTrue(
            restaurant.waitForExistence(timeout: 5)
        )
        restaurant.tap()

        let addButton = app.buttons["Adicionar Pizza Margherita"]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 5)
        )
        addButton.tap()

        app.buttons["FlowDelivery"].tap()

        let cartButton = app.buttons["Carrinho"]
        XCTAssertTrue(
            cartButton.waitForExistence(timeout: 5)
        )
        cartButton.tap()

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

        let confirmButton = app.buttons["Confirmar pedido"]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 5)
        )
        confirmButton.tap()

        let placeOrderButton = app.buttons["Fazer pedido"]
        XCTAssertTrue(
            placeOrderButton.waitForExistence(timeout: 5)
        )
        placeOrderButton.tap()

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
    }
}

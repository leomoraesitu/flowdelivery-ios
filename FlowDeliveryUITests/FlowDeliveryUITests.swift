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
}

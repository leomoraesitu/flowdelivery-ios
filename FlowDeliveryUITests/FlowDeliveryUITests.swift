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
        let app = makeOrderHistoryApp()

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
    func testUserSeesOrderHistoryError() {
        let app = makeOrderHistoryApp(
            launchArguments: [
                "-ui-testing-failing-order-repository"
            ]
        )

        XCTAssertTrue(
            app.navigationBars["Meus pedidos"].waitForExistence(
                timeout: 5
            )
        )

        XCTAssertTrue(
            app.staticTexts[
                "Não foi possível carregar seus pedidos."
            ].waitForExistence(timeout: 5)
        )

        XCTAssertTrue(
            app.buttons["Tentar novamente"].waitForExistence(
                timeout: 5
            )
        )
    }

    @MainActor
    func testUserCanRetryOrderHistoryLoading() {
        let app = makeOrderHistoryApp(
            launchArguments: [
                "-ui-testing-fail-once-order-history-repository"
            ]
        )

        let retryButton = app.buttons["Tentar novamente"]
        XCTAssertTrue(
            retryButton.waitForExistence(timeout: 5)
        )
        retryButton.tap()

        XCTAssertTrue(
            app.staticTexts["Nenhum pedido ainda"].waitForExistence(
                timeout: 5
            )
        )
    }

    @MainActor
    func testUserCanRetryOrderDetailsLoading() {
        let app = makeCheckoutApp(
            launchArguments: [
                "-ui-testing-fail-once-order-details-repository"
            ]
        )
        confirmOrder(in: app)

        let historyButton = app.buttons["Ver meus pedidos"]
        XCTAssertTrue(
            historyButton.waitForExistence(timeout: 5)
        )
        historyButton.tap()

        let orderRow = app.staticTexts["1 item"]
        XCTAssertTrue(
            orderRow.waitForExistence(timeout: 5)
        )
        orderRow.tap()

        XCTAssertTrue(
            app.staticTexts[
                "Não foi possível carregar os detalhes do pedido."
            ].waitForExistence(timeout: 5)
        )

        let retryButton = app.buttons["Tentar novamente"]
        XCTAssertTrue(
            retryButton.waitForExistence(timeout: 5)
        )
        retryButton.tap()

        XCTAssertTrue(
            app.staticTexts["Pizza Margherita"].waitForExistence(
                timeout: 5
            )
        )
    }

    @MainActor
    func testUserSeesMostRecentOrderFirst() {
        let app = makeOrderHistoryApp(
            launchArguments: [
                "-ui-testing-order-history-fixture-repository"
            ]
        )

        let orderRows = orderHistoryRows(
            in: app
        )

        let newerOrder = orderRows.element(
            boundBy: 0
        )

        let olderOrder = orderRows.element(
            boundBy: 1
        )

        XCTAssertTrue(
            newerOrder.waitForExistence(timeout: 5)
        )

        XCTAssertTrue(
            olderOrder.waitForExistence(timeout: 5)
        )

        XCTAssertLessThan(
            newerOrder.frame.minY,
            olderOrder.frame.minY
        )
    }

    @MainActor
    func testUserCanOpenMostRecentOrderDetails() {
        let app = makeOrderHistoryApp(
            launchArguments: [
                "-ui-testing-order-history-fixture-repository"
            ]
        )

        let orderRows = orderHistoryRows(
            in: app
        )

        let newerOrder = orderRows.element(
            boundBy: 0
        )
        XCTAssertTrue(
            newerOrder.waitForExistence(timeout: 5)
        )
        XCTAssertEqual(
            newerOrder.label,
            "Pedido com 2 itens, total R$ 99,80"
        )
        newerOrder.tap()

        XCTAssertTrue(
            app.navigationBars["Detalhes do pedido"].waitForExistence(
                timeout: 5
            )
        )

        let total = app.staticTexts["OrderDetails.Total"]
        XCTAssertTrue(
            total.waitForExistence(timeout: 5)
        )

        XCTAssertEqual(
            total.label,
            "Total, R$ 99,80"
        )
    }

    @MainActor
    func testOrderHistoryRowsExposeAccessibleSummaries() {
        let app = makeOrderHistoryApp(
            launchArguments: [
                "-ui-testing-order-history-fixture-repository"
            ]
        )

        let orderRows = orderHistoryRows(
            in: app
        )

        let newerOrder = orderRows.element(
            boundBy: 0
        )

        let olderOrder = orderRows.element(
            boundBy: 1
        )

        XCTAssertTrue(
            newerOrder.waitForExistence(timeout: 5)
        )

        XCTAssertTrue(
            olderOrder.waitForExistence(timeout: 5)
        )

        XCTAssertEqual(
            newerOrder.label,
            "Pedido com 2 itens, total R$ 99,80"
        )

        XCTAssertEqual(
            olderOrder.label,
            "Pedido com 1 item, total R$ 49,90"
        )
    }
}

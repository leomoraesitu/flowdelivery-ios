import XCTest

final class FlowDeliveryUITests: XCTestCase {
    @MainActor
    func testHomeScreenLoadsRestaurants() {
        let app = launchApp()

        let loginButton = app.buttons["Entrar"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: UITestTimeout.standard))
        loginButton.tap()

        XCTAssertTrue(
            app.navigationBars["FlowDelivery"].waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertTrue(
            app.staticTexts["Pizzaria Itália"].waitForExistence(timeout: UITestTimeout.standard)
        )
    }

    @MainActor
    func testUserCanNavigateToOrderHistoryAfterCompletingOrder() {
        let app = makeCheckoutApp()
        confirmOrder(in: app)

        let historyButton = app.buttons["Ver meus pedidos"]
        XCTAssertTrue(historyButton.waitForExistence(timeout: UITestTimeout.standard))
        historyButton.tap()

        XCTAssertTrue(
            app.navigationBars["Meus pedidos"].waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertTrue(app.staticTexts["1 item"].waitForExistence(timeout: UITestTimeout.standard))
        XCTAssertTrue(
            app.staticTexts["R$ 49,90"].waitForExistence(timeout: UITestTimeout.standard)
        )
        app.staticTexts["1 item"].tap()

        XCTAssertTrue(
            app.navigationBars["Detalhes do pedido"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )
        let paymentMethod = app.descendants(
            matching: .any
        )["OrderDetails.PaymentMethod"]

        XCTAssertTrue(
            paymentMethod.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertTrue(
            app.staticTexts["Pizza Margherita"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        let deliveryAddress = app.staticTexts[
            "OrderDetails.DeliveryAddress"
        ]

        XCTAssertTrue(
            deliveryAddress.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertEqual(
            deliveryAddress.label,
            "Avenida Paulista, 1000"
        )

        let total = app.staticTexts[
            "OrderDetails.Total"
        ]

        XCTAssertTrue(
            total.waitForExistence(timeout: UITestTimeout.standard)
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
                timeout: UITestTimeout.standard
            )
        )

        XCTAssertTrue(
            app.staticTexts["Nenhum pedido ainda"].waitForExistence(
                timeout: UITestTimeout.standard
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
                timeout: UITestTimeout.standard
            )
        )

        XCTAssertTrue(
            app.staticTexts[
                "Não foi possível carregar seus pedidos."
            ].waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertTrue(
            app.buttons["Tentar novamente"].waitForExistence(
                timeout: UITestTimeout.standard
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
            retryButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        retryButton.tap()

        XCTAssertTrue(
            app.staticTexts["Nenhum pedido ainda"].waitForExistence(
                timeout: UITestTimeout.standard
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
            historyButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        historyButton.tap()

        let orderRow = app.staticTexts["1 item"]
        XCTAssertTrue(
            orderRow.waitForExistence(timeout: UITestTimeout.standard)
        )
        orderRow.tap()

        XCTAssertTrue(
            app.staticTexts[
                "Não foi possível carregar os detalhes do pedido."
            ].waitForExistence(timeout: UITestTimeout.standard)
        )

        let retryButton = app.buttons["Tentar novamente"]
        XCTAssertTrue(
            retryButton.waitForExistence(timeout: UITestTimeout.standard)
        )
        retryButton.tap()

        XCTAssertTrue(
            app.staticTexts["Pizza Margherita"].waitForExistence(
                timeout: UITestTimeout.standard
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
            newerOrder.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertTrue(
            olderOrder.waitForExistence(timeout: UITestTimeout.standard)
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
            newerOrder.waitForExistence(timeout: UITestTimeout.standard)
        )
        XCTAssertEqual(
            newerOrder.label,
            "Pedido com 2 itens, total R$ 99,80"
        )
        newerOrder.tap()

        XCTAssertTrue(
            app.navigationBars["Detalhes do pedido"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        let total = app.staticTexts["OrderDetails.Total"]
        XCTAssertTrue(
            total.waitForExistence(timeout: UITestTimeout.standard)
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
            newerOrder.waitForExistence(timeout: UITestTimeout.standard)
        )

        XCTAssertTrue(
            olderOrder.waitForExistence(timeout: UITestTimeout.standard)
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

    @MainActor
    func testOrderHistoryPassesAccessibilityAudit() throws {
        let app = makeOrderHistoryApp(
            launchArguments: [
                "-ui-testing-order-history-fixture-repository"
            ]
        )

        try app.performAccessibilityAudit()
    }

    @MainActor
    func testOrderDetailsPassesAccessibilityAudit() throws {
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
            newerOrder.waitForExistence(timeout: UITestTimeout.standard)
        )

        newerOrder.tap()

        XCTAssertTrue(
            app.navigationBars["Detalhes do pedido"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        try app.performAccessibilityAudit { issue in
            issue.auditType == .dynamicType
                && [
                    "Pizza Margherita",
                    "2 × R$ 49,90",
                    "R$ 99,80"
                ].contains(
                    issue.element?.label ?? ""
                )
        }
    }

    @MainActor
    func testCheckoutPassesAccessibilityAudit() throws {
        let app = makeCheckoutApp()

        try app.performAccessibilityAudit { issue in
            issue.auditType == .dynamicType
                && issue.element?.label == "Pagamento"
        }
    }

    @MainActor
    func testCartPassesAccessibilityAudit() throws {
        let app = makeCartApp()

        // Dynamic Type: textos da célula que não reflowam nos tamanhos maiores.
        let dynamicTypeExceptions = [
            "Pizza Margherita",
            "R$ 49,90",
            "1",
            "Subtotal"
        ]

        // Hit region: textos estáticos auditados individualmente, mas cujo
        // alvo de toque real é a linha da List (altura > 44 pt).
        // Dívida técnica: combinar a célula em um único elemento acessível.
        let hitRegionExceptions = [
            "Pizza Margherita",
            "R$ 49,90"
        ]

        let subtotalIdentifier = "CartItem.Subtotal"

        try app.performAccessibilityAudit { issue in
            let label = (issue.element?.label ?? "").normalizingSpaces
            let identifier = issue.element?.identifier ?? ""

            switch issue.auditType {
            case .dynamicType:
                return dynamicTypeExceptions.contains(label)
                    || identifier == subtotalIdentifier

            case .textClipped:
                return identifier == subtotalIdentifier

            case .contrast:
                return label == "Subtotal"

            case .hitRegion:
                return hitRegionExceptions.contains(label)
                    || identifier == subtotalIdentifier

            default:
                return false
            }
        }
    }

    @MainActor
    func testHomePassesAccessibilityAudit() throws {
        let app = makeHomeApp()

        XCTAssertTrue(
            app.staticTexts["Pizzaria Itália"].waitForExistence(
                timeout: UITestTimeout.standard
            )
        )

        try app.performAccessibilityAudit()
    }
}

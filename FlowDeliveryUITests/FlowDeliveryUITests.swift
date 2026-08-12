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
}

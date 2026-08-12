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
}

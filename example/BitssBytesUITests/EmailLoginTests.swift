import XCTest

class EmailLoginTests: BaseTestCase {

    func testLoginSuccess() {
        navigateToSignIn()
        app.textFields["SignInEmailScreenView_emailInput"].clearAndType(TestCredentials.email)
        app.secureTextFields["SignInEmailScreenView_passInput"].clearAndType(TestCredentials.password)
        app.buttons["SignInEmailScreenView_loginButton"].tap()
        waitForElement(app.buttons["LoggedIn_logoutButton"])
        XCTAssertTrue(app.buttons["LoggedIn_logoutButton"].exists)
    }

    func testLoginWrongPassword() {
        navigateToSignIn()
        app.textFields["SignInEmailScreenView_emailInput"].clearAndType(TestCredentials.email)
        app.secureTextFields["SignInEmailScreenView_passInput"].clearAndType("wrong_password_123")
        app.buttons["SignInEmailScreenView_loginButton"].tap()
        waitForElement(app.staticTexts["SignInEmailScreenView_errorLabel"])
        XCTAssertTrue(app.staticTexts["SignInEmailScreenView_errorLabel"].exists)
    }

    func testLoginEmptyFields() {
        navigateToSignIn()
        app.buttons["SignInEmailScreenView_loginButton"].tap()
        let errorLabel = app.staticTexts["SignInEmailScreenView_errorLabel"]
        waitForElement(errorLabel)
        XCTAssertTrue(errorLabel.exists)
    }
}

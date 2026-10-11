import XCTest

class ForgotPasswordTests: BaseTestCase {

    func testForgotPasswordSuccess() {
        navigateToSignIn()
        app.buttons["SignInEmailScreenView_forgotPasswordButton"].waitAndTap()
        app.textFields["ResetPasswordScreenView_emailInput"].clearAndType(TestCredentials.email)
        app.buttons["ResetPasswordScreenView_resetButton"].tap()
        waitForElement(app.staticTexts["ResetPasswordScreenView_passSentLabel"])
        XCTAssertTrue(app.staticTexts["ResetPasswordScreenView_passSentLabel"].exists)
    }

    func testForgotPasswordUnknownEmail() {
        navigateToSignIn()
        app.buttons["SignInEmailScreenView_forgotPasswordButton"].waitAndTap()
        app.textFields["ResetPasswordScreenView_emailInput"].clearAndType("nobody@nowhere.com")
        app.buttons["ResetPasswordScreenView_resetButton"].tap()
        waitForElement(app.staticTexts["ResetPasswordScreenView_errorLabel"])
        XCTAssertTrue(app.staticTexts["ResetPasswordScreenView_errorLabel"].exists)
    }
}

import XCTest

class ChangePasswordTests: BaseTestCase {

    func testChangePasswordSuccess() {
        loginWithEmail()
        app.staticTexts["Change Password"].waitAndTap()
        app.secureTextFields["ChangePasswordScreenView_currentPassInput"].clearAndType(TestCredentials.password)
        // Use same password to avoid leaving the account in a broken state
        app.secureTextFields["ChangePasswordScreenView_newPassInput"].clearAndType(TestCredentials.password)
        app.secureTextFields["ChangePasswordScreenView_confirmPassInput"].clearAndType(TestCredentials.password)
        app.buttons["ChangePasswordScreenView_saveButton"].tap()
        sleep(2)
        XCTAssertFalse(app.staticTexts["ChangePasswordScreenView_errorLabel"].exists)
        XCTAssertTrue(app.buttons["LoggedIn_logoutButton"].exists)
    }

    func testChangePasswordWrongCurrent() {
        loginWithEmail()
        app.staticTexts["Change Password"].waitAndTap()
        app.secureTextFields["ChangePasswordScreenView_currentPassInput"].clearAndType("WrongPass999!")
        app.secureTextFields["ChangePasswordScreenView_newPassInput"].clearAndType(TestCredentials.password)
        app.secureTextFields["ChangePasswordScreenView_confirmPassInput"].clearAndType(TestCredentials.password)
        app.buttons["ChangePasswordScreenView_saveButton"].tap()
        waitForElement(app.staticTexts["ChangePasswordScreenView_errorLabel"])
        XCTAssertTrue(app.staticTexts["ChangePasswordScreenView_errorLabel"].exists)
    }
}

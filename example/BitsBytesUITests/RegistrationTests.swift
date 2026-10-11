import XCTest

class RegistrationTests: BaseTestCase {

    func testRegisterSuccess() {
        navigateToRegister()
        let randomEmail = "bitsbytes+\(Int.random(in: 10000...99999))@mailinator.com"
        app.textFields["RegisterScreenView_firstNameInput"].clearAndType(TestCredentials.firstName)
        app.textFields["RegisterScreenView_lastNameInput"].clearAndType(TestCredentials.lastName)
        app.textFields["RegisterScreenView_emailInput"].clearAndType(randomEmail)
        app.secureTextFields["RegisterScreenView_passInput"].clearAndType(TestCredentials.password)
        app.secureTextFields["RegisterScreenView_confirmpassInput"].clearAndType(TestCredentials.password)
        app.buttons["RegisterScreenView_registerButton"].tap()
        waitForElement(app.buttons["LoggedIn_logoutButton"], timeout: 20)
        XCTAssertTrue(app.buttons["LoggedIn_logoutButton"].exists)
    }

    func testRegisterEmptyFields() {
        navigateToRegister()
        app.buttons["RegisterScreenView_registerButton"].tap()
        XCTAssertTrue(app.staticTexts["RegisterScreenView_firstNameEmptyError"].exists)
        XCTAssertTrue(app.staticTexts["RegisterScreenView_emailEmptyError"].exists)
        XCTAssertTrue(app.staticTexts["RegisterScreenView_passEmptyError"].exists)
    }

    func testRegisterPasswordMismatch() {
        navigateToRegister()
        app.textFields["RegisterScreenView_firstNameInput"].clearAndType(TestCredentials.firstName)
        app.textFields["RegisterScreenView_lastNameInput"].clearAndType(TestCredentials.lastName)
        app.textFields["RegisterScreenView_emailInput"].clearAndType("mismatch@test.com")
        app.secureTextFields["RegisterScreenView_passInput"].clearAndType(TestCredentials.password)
        app.secureTextFields["RegisterScreenView_confirmpassInput"].clearAndType("DifferentPass1!")
        app.buttons["RegisterScreenView_registerButton"].tap()
        waitForElement(app.staticTexts["RegisterScreenView_confirmpassEmptyError"])
        XCTAssertTrue(app.staticTexts["RegisterScreenView_confirmpassEmptyError"].exists)
    }
}

import XCTest

class T01_RegistrationTests: BaseTestCase {

    private func fillRegistrationForm(email: String) {
        app.textFields["RegisterScreenView_firstNameInput"].clearAndType(TestCredentials.firstName)
        app.textFields["RegisterScreenView_lastNameInput"].clearAndType(TestCredentials.lastName)
        app.textFields["RegisterScreenView_emailInput"].clearAndType(email)
        // Dismiss QuickType/autocomplete bar before moving to password fields —
        // tapping a SecureTextField while a suggestion is shown can misdirect the tap
        app.textFields["RegisterScreenView_emailInput"].typeText("\n")
        app.secureTextFields["RegisterScreenView_passInput"].clearAndType(TestCredentials.password)
        app.secureTextFields["RegisterScreenView_confirmpassInput"].clearAndType(TestCredentials.password)
        app.swipeUp()
    }
    
    // Must run first — generates a random email, registers it, and saves it to a temp file
    // so EmailLoginTests and other tests can use the same account.
    func testRegisterSuccess() {
        let randomEmail = "bitsbytes+\(Int.random(in: 10000...99999))@gmail.com"
        TestCredentials.email = randomEmail

        navigateToRegister()
        fillRegistrationForm(email: randomEmail)
        app.buttons["RegisterScreenView_registerButton"].tap()
        dismissSavePasswordSheet()

        let result = XCTWaiter().wait(
            for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == 1"), object: logoutRow)],
            timeout: 30
        )
        guard result == .completed else {
            let errorLabel = app.staticTexts["RegisterScreenView_errorLabel"]
            let errorMsg = (errorLabel.exists && !errorLabel.label.isEmpty) ? errorLabel.label : "timeout waiting for logout button"
            XCTFail("Registration failed: \(errorMsg)")
            return
        }
        XCTAssertTrue(logoutRow.exists, "Expected to be logged in after registration")
        tapLogout()
        waitForElement(app.buttons["Profile_signinButton"])
        XCTAssertTrue(app.buttons["Profile_signinButton"].exists, "Expected to be logged out after tapping logout")
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
        app.textFields["RegisterScreenView_emailInput"].typeText("\n")
        app.secureTextFields["RegisterScreenView_passInput"].clearAndType(TestCredentials.password)
        app.secureTextFields["RegisterScreenView_confirmpassInput"].clearAndType("DifferentPass1!")
        app.swipeUp()
        app.buttons["RegisterScreenView_registerButton"].tap()
        // Mismatch sets viewModel.error = "Password not match." → shown as errorLabel
        let errorLabel = app.staticTexts["RegisterScreenView_errorLabel"]
        waitForElement(errorLabel)
        XCTAssertTrue(errorLabel.exists)
        XCTAssertEqual(errorLabel.label, "Password not match.")
    }
}

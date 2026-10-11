import XCTest

class InterruptionTests: BaseTestCase {

    func testPendingRegistration() {
        // Requires a Google test account pre-configured in CDC console to require birthday on first login
        app.otherElements["profileTabButton"].waitAndTap()
        app.buttons["Profile_signinButton"].waitAndTap()
        addUIInterruptionMonitor(withDescription: "Google sign-in webview") { alert in
            if alert.buttons["Continue"].exists { alert.buttons["Continue"].tap(); return true }
            return false
        }
        app.buttons["SignInScreenView_googleButton"].waitAndTap()
        let webEmailField = app.webViews.textFields.firstMatch
        if webEmailField.waitForExistence(timeout: 10) {
            webEmailField.clearAndType(TestCredentials.Google.email)
            app.webViews.buttons["Next"].tap()
            app.webViews.secureTextFields.firstMatch.clearAndType(TestCredentials.Google.password)
            app.webViews.buttons["Next"].tap()
        }
        // SDK interruption auto-navigates to PenddingRegistrationScreenView
        waitForElement(app.datePickers["PenddingRegistrationScreenView_birthDayInput"], timeout: 20)
        XCTAssertTrue(app.datePickers["PenddingRegistrationScreenView_birthDayInput"].exists)
        app.datePickers["PenddingRegistrationScreenView_birthDayInput"].tap()
        app.buttons["PenddingRegistrationScreenView_saveButton"].waitAndTap()
        waitForElement(app.buttons["LoggedIn_logoutButton"], timeout: 20)
        XCTAssertTrue(app.buttons["LoggedIn_logoutButton"].exists)
    }
}

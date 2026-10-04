import XCTest

class SocialLoginTests: BaseTestCase {

    func testGoogleLogin() {
        app.buttons["profileTabButton"].tap()
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
        waitForElement(app.buttons["LoggedIn_logoutButton"], timeout: 30)
        XCTAssertTrue(app.buttons["LoggedIn_logoutButton"].exists)
    }
}

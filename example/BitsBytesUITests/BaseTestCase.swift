import XCTest

open class BaseTestCase: XCTestCase {
    var app: XCUIApplication!

    override open func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--Reset"]
        app.launch()
        // Dismiss any system interruptions (e.g. "Use Strong Password?", autofill sheets)
        addUIInterruptionMonitor(withDescription: "System sheet") { alert in
            if alert.buttons["Not Now"].exists {
                alert.buttons["Not Now"].tap()
                return true
            }
            if alert.buttons["Cancel"].exists {
                alert.buttons["Cancel"].tap()
                return true
            }
            // "Use Strong Password?" sheet has a circular X dismiss button
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            if springboard.buttons["Close"].exists {
                springboard.buttons["Close"].tap()
                return true
            }
            // Fallback: tap the first button in the alert (usually dismiss/cancel)
            if alert.buttons.count > 0 {
                alert.buttons.element(boundBy: 0).tap()
                return true
            }
            return false
        }
        waitForSplash()
    }

    // Splash covers the UI for ~1s on launch — wait for it to dismiss
    // before any test interaction, otherwise tab bar taps silently fail.
    private func waitForSplash() {
        let tabBar = app.otherElements["homeTabButton"]
        let predicate = NSPredicate(format: "exists == 1")
        expectation(for: predicate, evaluatedWith: tabBar)
        waitForExpectations(timeout: 10)
    }

    override open func tearDown() {
        GigyaUtils.logout()
        super.tearDown()
    }

    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 15) {
        let predicate = NSPredicate(format: "exists == 1")
        expectation(for: predicate, evaluatedWith: element)
        waitForExpectations(timeout: timeout)
    }

    // The logout row's Button node has no direct identifier in the accessibility tree —
    // the identifier lands on its child StaticText. Use the StaticText to detect login state,
    // and tap the button by finding it via its child label.
    var logoutRow: XCUIElement { app.staticTexts["LoggedIn_logoutButton"] }

    func tapLogout() {
        // Scroll down to make the logout row visible before tapping
        tapProfileTab()
        app.swipeUp()
        logoutRow.waitAndTap()
    }
    func tapProfileTab() {
        app.otherElements["profileTabButton"].waitAndTap()
    }

    func navigateToSignIn() {
        tapProfileTab()
        app.buttons["Profile_signinButton"].waitAndTap()
        app.buttons["SignInScreenView_emailButton"].waitAndTap()
    }

    func navigateToRegister() {
        tapProfileTab()
        app.buttons["Profile_registerButton"].waitAndTap()
    }

    func loginWithEmail() {
        navigateToSignIn()
        app.textFields["SignInEmailScreenView_emailInput"].clearAndType(TestCredentials.email)
        app.textFields["SignInEmailScreenView_emailInput"].typeText("\n")
        app.secureTextFields["SignInEmailScreenView_passInput"].clearAndType(TestCredentials.password)
        app.swipeDown()
        app.buttons["SignInEmailScreenView_loginButton"].tap()
        dismissSavePasswordSheet()
        waitForElement(logoutRow, timeout: 20)
    }

    // "Save Password?" / "Save this password?" sheet appears after a successful login.
    // It's a system sheet rendered in the app window — not a system alert, so the
    // interruption monitor doesn't catch it. Dismiss it explicitly.
    func dismissSavePasswordSheet() {
        let notNow = app.buttons["Not Now"]
        let neverForWebsite = app.buttons["Never for This Website"]
        let cancel = app.buttons["Cancel"]
        for button in [notNow, neverForWebsite, cancel] {
            if button.waitForExistence(timeout: 2) {
                button.tap()
                return
            }
        }
    }
}

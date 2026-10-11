import XCTest

open class BaseTestCase: XCTestCase {
    var app: XCUIApplication!

    override open func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--Reset"]
        app.launch()
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

    // Tab bar items are SwiftUI Images with onTapGesture, not Buttons —
    // XCUITest exposes them under otherElements, not buttons.
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
        app.secureTextFields["SignInEmailScreenView_passInput"].clearAndType(TestCredentials.password)
        app.buttons["SignInEmailScreenView_loginButton"].tap()
        waitForElement(app.buttons["LoggedIn_logoutButton"], timeout: 20)
    }
}

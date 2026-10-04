import XCTest

class LogoutTests: BaseTestCase {

    func testLogout() {
        loginWithEmail()
        app.buttons["LoggedIn_logoutButton"].tap()
        waitForElement(app.buttons["Profile_signinButton"])
        XCTAssertTrue(app.buttons["Profile_signinButton"].exists)
    }
}

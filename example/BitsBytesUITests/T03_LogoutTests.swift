import XCTest

class T03_LogoutTests: BaseTestCase {

    func testLogout() {
        loginWithEmail()
        
        tapLogout()
        waitForElement(app.buttons["Profile_signinButton"])
        XCTAssertTrue(app.buttons["Profile_signinButton"].exists)
    }

    // Standalone logout test — logs in, then tries every possible way to find and tap logout.
    // Run this alone to debug the logout element until it works reliably.
    func testLogoutDebug() {
        print("Using email: \(TestCredentials.email)")
        loginWithEmail()

        print("=== TREE AFTER LOGIN ===")
        print(app.debugDescription)
        print("=== END TREE ===")

        // Try 1: staticTexts by identifier
        let byStaticText = app.staticTexts["LoggedIn_logoutButton"]
        print("staticTexts[LoggedIn_logoutButton] exists: \(byStaticText.exists)")

        // Try 2: buttons by identifier
        let byButton = app.buttons["LoggedIn_logoutButton"]
        print("buttons[LoggedIn_logoutButton] exists: \(byButton.exists)")

        // Try 3: otherElements by identifier
        let byOther = app.otherElements["LoggedIn_logoutButton"]
        print("otherElements[LoggedIn_logoutButton] exists: \(byOther.exists)")

        // Try 4: any element by identifier
        let byAny = app.descendants(matching: .any).matching(identifier: "LoggedIn_logoutButton").firstMatch
        print("any[LoggedIn_logoutButton] exists: \(byAny.exists), type: \(byAny.elementType.rawValue)")

        // Try 5: staticText with label "Logout"
        let byLabel = app.staticTexts["Logout"]
        print("staticTexts[Logout] exists: \(byLabel.exists)")

        XCTAssertTrue(byAny.exists, "Could not find logout element by any query")
    }
}

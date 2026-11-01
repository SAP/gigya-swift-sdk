import XCTest

class T02_EmailLoginTests: BaseTestCase {

    func testLoginSuccess() {
        navigateToSignIn()
        app.textFields["SignInEmailScreenView_emailInput"].clearAndType(TestCredentials.email)
        app.textFields["SignInEmailScreenView_emailInput"].typeText("\n")
        app.secureTextFields["SignInEmailScreenView_passInput"].clearAndType(TestCredentials.password)
        app.swipeDown()
        app.buttons["SignInEmailScreenView_loginButton"].tap()
        waitForElement(logoutRow)
        XCTAssertTrue(logoutRow.exists)
    }

    // Debug test — logs in with the registered email, dumps the accessibility tree,
    // and tries every possible query for the logout element.
    func testLoginDebug() {
        print("Using email: \(TestCredentials.email)")
        navigateToSignIn()
        app.textFields["SignInEmailScreenView_emailInput"].clearAndType(TestCredentials.email)
        app.textFields["SignInEmailScreenView_emailInput"].typeText("\n")
        app.secureTextFields["SignInEmailScreenView_passInput"].clearAndType(TestCredentials.password)
        app.swipeDown()
        app.buttons["SignInEmailScreenView_loginButton"].tap()

        sleep(5)

        print("=== TREE AFTER LOGIN ===")
        print(app.debugDescription)
        print("=== END TREE ===")

        let byStaticText = app.staticTexts["LoggedIn_logoutButton"]
        print("staticTexts[LoggedIn_logoutButton] exists: \(byStaticText.exists)")

        let byButton = app.buttons["LoggedIn_logoutButton"]
        print("buttons[LoggedIn_logoutButton] exists: \(byButton.exists)")

        let byOther = app.otherElements["LoggedIn_logoutButton"]
        print("otherElements[LoggedIn_logoutButton] exists: \(byOther.exists)")

        let byAny = app.descendants(matching: .any).matching(identifier: "LoggedIn_logoutButton").firstMatch
        print("any[LoggedIn_logoutButton] exists: \(byAny.exists), type: \(byAny.elementType.rawValue)")

        let byLabel = app.staticTexts["Logout"]
        print("staticTexts[Logout] exists: \(byLabel.exists)")

        XCTAssertTrue(byAny.exists, "Could not find logout element by any query")
    }

    func testLoginWrongPassword() {
        navigateToSignIn()
        app.textFields["SignInEmailScreenView_emailInput"].clearAndType(TestCredentials.email)
        app.textFields["SignInEmailScreenView_emailInput"].typeText("\n")
        app.secureTextFields["SignInEmailScreenView_passInput"].clearAndType("wrong_password_123")
        app.swipeDown()
        app.buttons["SignInEmailScreenView_loginButton"].tap()
        waitForElement(app.staticTexts["SignInEmailScreenView_errorLabel"])
        XCTAssertTrue(app.staticTexts["SignInEmailScreenView_errorLabel"].exists)
    }

    func testLoginEmptyFields() {
        navigateToSignIn()
        app.buttons["SignInEmailScreenView_loginButton"].tap()
        let errorLabel = app.staticTexts["SignInEmailScreenView_errorLabel"]
        waitForElement(errorLabel)
        XCTAssertTrue(errorLabel.exists)
    }
}

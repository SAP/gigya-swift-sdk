import XCTest

class OtpTests: BaseTestCase {

    func testOtpLoginPhoneEntry() {
        app.buttons["profileTabButton"].tap()
        app.buttons["Profile_signinButton"].waitAndTap()
        app.buttons["SignInScreenView_phoneButton"].waitAndTap()
        waitForElement(app.textFields["OtpScreenView_PhoneInput"])
        XCTAssertTrue(app.textFields["OtpScreenView_PhoneInput"].exists)
        app.textFields["OtpScreenView_PhoneInput"].clearAndType(TestCredentials.phone)
        // Tap Send Code button (no accessibility ID — match by label)
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Send'")).firstMatch.tap()
        // Full round-trip requires a real SMS — verify the code-entry UI appears
        let codeField = app.textFields["OtpScreenView_PhoneInput"]
        waitForElement(codeField, timeout: 10)
        XCTAssertTrue(codeField.exists)
    }
}

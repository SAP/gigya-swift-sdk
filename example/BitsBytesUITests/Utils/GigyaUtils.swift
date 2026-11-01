import XCTest

struct GigyaUtils {
    static func logout() {
        let app = XCUIApplication()
        app.launchArguments = []
        app.launch()
        // Navigate to profile tab and scroll down so the logout row is visible
        let profileTab = app.otherElements["profileTabButton"]
        if profileTab.waitForExistence(timeout: 5) {
            profileTab.tap()
            app.swipeUp()
        }
        let logoutText = app.staticTexts["LoggedIn_logoutButton"]
        if logoutText.waitForExistence(timeout: 3) {
            logoutText.tap()
        }
    }
}

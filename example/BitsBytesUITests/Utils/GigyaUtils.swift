import XCTest

struct GigyaUtils {
    static func logout() {
        let app = XCUIApplication()
        app.launchArguments = []
        app.launch()
        let logoutButton = app.buttons["LoggedIn_logoutButton"]
        if logoutButton.waitForExistence(timeout: 3) {
            logoutButton.tap()
        }
    }
}

import XCTest

class ProfileUpdateTests: BaseTestCase {

    func testUpdateFirstName() {
        loginWithEmail()
        app.staticTexts["About Me"].waitAndTap()
        let newName = "Name\(Int.random(in: 1000...9999))"
        app.textFields["AboutMeScreenView_fnameInput"].clearAndType(newName)
        app.buttons["AboutMeScreenView_saveButton"].tap()
        app.navigationBars.buttons.firstMatch.tap()
        app.staticTexts["About Me"].waitAndTap()
        waitForElement(app.textFields["AboutMeScreenView_fnameInput"])
        XCTAssertEqual(app.textFields["AboutMeScreenView_fnameInput"].value as? String, newName)
    }
}

import XCTest

extension XCUIElement {
    func clearAndType(_ text: String) {
        tap()
        if elementType == .secureTextField {
            dismissPasswordSuggestionSheet()
        }
        if let current = value as? String, !current.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count)
            typeText(deleteString)
        }
        typeText(text)
    }

    // "Use Strong Password?" is a UIKit keyboard accessory rendered inside the app window,
    // not a system alert — interruption monitors don't fire for it. After tapping a
    // SecureTextField, wait briefly for the sheet and dismiss its close button before typing.
    private func dismissPasswordSuggestionSheet() {
        let app = XCUIApplication()

        // Strategy 1: sheet exposes itself as an otherElement with this accessibility label
        let sheet = app.otherElements["Use Strong Password?"]
        if sheet.waitForExistence(timeout: 1.5) {
            let closeBtn = sheet.buttons.firstMatch
            if closeBtn.exists { closeBtn.tap(); return }
        }

        // Strategy 2: a "Close" button appears directly in the app hierarchy
        let closeButton = app.buttons["Close"]
        if closeButton.waitForExistence(timeout: 0.5) {
            closeButton.tap()
            return
        }

        // Strategy 3: the sheet may contain a static text with this label,
        // and the dismiss button is the last button before the keyboard accessory bar.
        // Tap the X at the known visual position (top-right of the suggestion sheet).
        let passwordSheetText = app.staticTexts["Use Strong Password?"]
        if passwordSheetText.waitForExistence(timeout: 0.5) {
            // The sheet sits just above the keyboard; its X button is in its trailing corner.
            // Tap slightly to the left of the screen's right edge, at the sheet's vertical center.
            let screenWidth = app.windows.firstMatch.frame.width
            let sheetMidY = passwordSheetText.frame.midY
            app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
                .withOffset(CGVector(dx: screenWidth - 30, dy: sheetMidY))
                .tap()
        }
    }

    func waitAndTap(timeout: TimeInterval = 10) {
        // Wait for existence only — onTapGesture elements (e.g. SwiftUI Image tabs)
        // are never reported as isHittable by XCUITest even when fully visible.
        let predicate = NSPredicate(format: "exists == 1")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        tap()
    }
}

import XCTest

extension XCUIElement {
    func clearAndType(_ text: String) {
        tap()
        guard let currentValue = value as? String, !currentValue.isEmpty else {
            typeText(text); return
        }
        let deleteChars = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        typeText(deleteChars)
        typeText(text)
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

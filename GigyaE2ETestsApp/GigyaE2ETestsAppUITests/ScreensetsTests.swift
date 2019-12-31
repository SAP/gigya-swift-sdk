//
//  ScreensetsTests.swift
//  GigyaE2ETestsAppUITests
//
//  Created by Shmuel, Sagi on 12/12/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest

class ScreensetsTests: XCTestCase {
    var app: XCUIApplication = XCUIApplication()

    let randomEmail = "\(Int.random(in: 50000...100000))@\(Int.random(in: 50000...100000)).com"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

        app.launch()

        app.buttons["screensets"].tap()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        GeneralGigyaUtils.logout()
    }

    func testRegister() {
        app.buttons["siteRegister"].tap()

        let exists = NSPredicate(format: "exists == 1")

        let regLink = app.links["Don't have an account yet?"]

        expectation(for: exists, evaluatedWith: regLink, handler: nil)

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertTrue(regLink.exists)

        regLink.tap()

        let email = app.textFields.element(boundBy: 0)

        expectation(for: exists, evaluatedWith: email, handler: nil)

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertTrue(email.exists)

        app.textFields.element(boundBy: 1).tap()
        app.typeText("test")

        app.textFields.element(boundBy: 2).tap()
        app.typeText("test")

        app.toolbars.buttons["Done"].tap()

        email.tap()
        app.typeText(randomEmail)

        app.toolbars.buttons["Done"].tap()


        app.secureTextFields.element(boundBy: 0).tap()
        app.typeText("151515")

        app.secureTextFields.element(boundBy: 1).tap()
        app.typeText("151515")

        app.buttons["Submit"].tap()

        sleep(2)
        let uid = app.staticTexts["uid"]

        XCTAssertNotEqual(uid.label, "error")

    }

    func testLogin() {
        loginWithEmail("sagishm+10@gmail.com")

        sleep(2)
        let uid = app.staticTexts["uid"]

        XCTAssertNotEqual(uid.label, "error")

    }

    func loginWithEmail(_ emailString: String) {
        app.buttons["siteLogin"].tap()

        let exists = NSPredicate(format: "exists == 1")

        let email = app.textFields.element(boundBy: 0)

        expectation(for: exists, evaluatedWith: email, handler: nil)

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertTrue(email.exists)

        email.tap()
        app.typeText(emailString)

        app.toolbars.buttons["Done"].tap()

        app.secureTextFields.element(boundBy: 0).tap()
        app.typeText("151515")

        app.buttons["Submit"].tap()
    }
}

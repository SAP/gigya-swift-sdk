//
//  LoginTestsUi.swift
//  TestAppUITests
//
//  Created by Shmuel, Sagi on 16/09/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest

class LoginTestsUi: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogin() {
        app.launch()

        app.buttons["Login"].tap()

        let email = app.textFields["Email"]
        email.tap()
        email.typeText("sagi.shmuel@sap.com")

        let pass = app.textFields["Password"]
        pass.tap()
        pass.typeText("151515")

        app.buttons["Submit"].tap()

        let text = app.staticTexts["Logged out"]

        let exists = NSPredicate(format: "exists != 1")

        expectation(for: exists, evaluatedWith: text, handler: nil)

        waitForExpectations(timeout: 5, handler: nil)

//        GeneraUITestHelper.testLogout(app: app)

    }

    func testAddConnection() {
        app.launch()
        
        app.buttons["AddConnection"].tap()

        let pass = app.textFields["Provider"]
        pass.tap()
        pass.typeText("facebbok")

        app.buttons["Add"].tap()
        sleep(1)

        app.buttons["Continue"].tap()


        let continueButton = app.buttons["Continue"]

        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: continueButton, handler: nil)

        waitForExpectations(timeout: 5, handler: nil)

        continueButton.tap()

    }

}

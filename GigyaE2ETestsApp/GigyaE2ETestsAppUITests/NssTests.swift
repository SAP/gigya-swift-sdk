//
//  NssTests.swift
//  GigyaE2ETestsAppUITests
//
//  Created by Shmuel, Sagi on 12/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import XCTest

class NssTests: XCTestCase {
    var app: XCUIApplication = XCUIApplication()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

        app.launchArguments = ["--Reset"]
        app.launch()

        app.buttons["nss"].tap()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        GeneralGigyaUtils.logout()
    }

    func testLoginSuccessful() {
        app.buttons["siteLogin"].tap()

        sleep(5)

        let email = app.textViews["Email"]

        email.tap()
        email.typeText("sagishm@gmail.com")

        email.typeText("\n")

        let pass = app.textViews["Password"]
        pass.tap()
        pass.typeText("151515")

        app.buttons["Submit"].tap()

        let uid = app.staticTexts["uid"]
        
        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: uid, handler: nil)

        waitForExpectations(timeout: 8, handler: nil)

        XCTAssertTrue(uid.exists)

        XCTAssertNotEqual(uid.label, "error")

    }

    func testRegisterSuccessful() {
        app.buttons["siteRegister"].tap()

        sleep(5)

        let email = app.textViews["Email"]

        email.tap()

        let randomUser: Int = Int(arc4random_uniform(50000));

        email.typeText("\(randomUser)@a.com")

        email.typeText("\n")


        let pass = app.textViews["Password"]
        pass.tap()
        pass.typeText("151515")

        app.buttons["Submit"].tap()

        let uid = app.staticTexts["uid"]

        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: uid, handler: nil)

        waitForExpectations(timeout: 8, handler: nil)

        XCTAssertTrue(uid.exists)

        XCTAssertNotEqual(uid.label, "error")

    }

    func testLoginError() {
        app.buttons["siteLogin"].tap()

        sleep(5)

        let email = app.textViews["Email"]

        email.tap()
        email.typeText("sagishm@gmail.com")

        email.typeText("\n")


        let pass = app.textViews["Password"]
        pass.tap()
        pass.typeText("121212")

        app.buttons["Submit"].tap()

        let error = app.otherElements["Invalid LoginID"]

        sleep(2)

        XCTAssertTrue(error.exists)
    }

    func testUpdateProfileShowing() {

        testLoginSuccessful()

        sleep(1)

        app.buttons["done"].tap()

        app.buttons["updateProfile"].tap()

        let fname = app.textViews["First name"].value as? String ?? ""
        let lname = app.textViews["Last name"].value as? String ?? ""
        let email = app.textViews["Email"].value as? String ?? ""
        let zip = app.textViews["Zipcode"].value as? String ?? ""
        let country = app.textViews["Country"].value as? String ?? ""

        XCTAssertEqual(fname, "Sagi")
        XCTAssertEqual(lname, "Shmuel")
        XCTAssertEqual(email, "sagishm@gmail.com")
        XCTAssertEqual(zip, "23432432")
        XCTAssertEqual(country, "Israel")
    }

}

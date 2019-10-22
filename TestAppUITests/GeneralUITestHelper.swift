//
//  GeneralUITestHelper.swift
//  TestAppUITests
//
//  Created by Shmuel, Sagi on 16/09/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest

class GeneraUITestHelper {
    static public func testLogout(app: XCUIApplication) {
        app.launch()

//        XCTAssertTrue(app.isHomeScreen)

        let logout = app.buttons["Logout"]

        logout.tap()

        sleep(1)
    }
}

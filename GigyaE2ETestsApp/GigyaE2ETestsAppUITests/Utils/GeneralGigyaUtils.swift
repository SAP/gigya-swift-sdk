//
//  GeneralGigyaUtils.swift
//  GigyaE2ETestsAppUITests
//
//  Created by Shmuel, Sagi on 11/12/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class GeneralGigyaUtils {

    static func logout() {
        var app: XCUIApplication = XCUIApplication()
        
        app.launch()

        app.buttons["logout"].tap()

        sleep(2)
    }
}

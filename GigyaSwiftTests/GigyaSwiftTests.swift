//
//  GigyaSwiftTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 20/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya
@testable import GigyaNss

class GigyaSwiftTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        var screenModel: ScreenEventModel = ScreenEventModel()

        screenModel.nextRoute = "dasdsad"
        print(screenModel.nextRoute)
    }

}

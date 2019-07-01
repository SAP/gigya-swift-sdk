//
//  GigyaLoggerTest.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 10/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class GigyaLoggerTest: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSetDebugToTrue() {
        GigyaLogger.setDebugMode(to: true)
        XCTAssert(GigyaLogger.isDebug())
    }

    func testMakeStringFromClass() {
        XCTAssertNotNil(GigyaLogger.genericName(self))
    }


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

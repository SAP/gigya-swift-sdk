//
//  GigyaLoggerTest.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 10/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

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

    func testss () {

        let url = URL(string: "gsapi://login_result#access_token=st2.c6OvlRfuP7Od5QjCz5Jbszwf-ks.2AJgzXaU-Y-AxSsfZinXmw.PaUSg2Uj2SgPsuw43A3qluK_Eeg&x_access_token_secret=BoJY59BdjAYc41gnkjOtXd10Cd4%3d&expires_in=0&status=ok")!

        let mode     = url["access_token"]
        let referrer = url["x_access_token_secret"]  // "blah"
          // "blahblah"

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

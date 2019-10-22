//
//  URLTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 07/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class URLTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUrlSubscript() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let url = URL(string: "http://gigya.com/#a=a&b=b")!

        XCTAssertEqual(url["a"], "a")
        XCTAssertEqual(url["b"], "b")

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

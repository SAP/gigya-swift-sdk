//
//  PKCE.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 21/11/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

@available(iOS 13.0, *)
class PKCETests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let pkce = try! PKCEHelper()

        print("verifier:")
        print(pkce.verifier)
        print("challenge:")
        print(pkce.challenge)

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

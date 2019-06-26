//
//  StringTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 23/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class StringsTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testGetStringBySubscript() {
        let string = "url?param1=true&param2=false"

        if let param1 = string["param1"] {
            XCTAssertEqual(param1, "true")
        }
    }

    func testGetStringFailed() {
        let string = "url?param1=true&param2=false"

        if let _ = string["param3"] {
            XCTFail()
        } else {
            XCTAssert(true)
        }
    }

    func testStringToDictionary() {
        let string = "url?param1=true&param2=false"

        let asDictionary = string.asDictionary()

        XCTAssertEqual(asDictionary.count, 2)
    }

    func testDictionaryToJson() {
        let string: [String: Any] = ["fail": "GigyaConfig.self"]

        let asDictionary = string.asJson

        XCTAssertEqual(asDictionary, "{\"fail\":\"GigyaConfig.self\"}")

    }

//    func testDictionaryToJsonFailed() {
//        let string: [String: Any] = ["j": Data()]
//
//        let asDictionary = string.asJson
//
//        XCTAssertEqual(asDictionary, "{\"fail\":\"GigyaConfig.self\"}")
//
//    }


}


//
//  AnyCodableTest.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 11/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class AnyCodableTest: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testString() {
        let data = ["test"]
        do {
            let decode = try DecodeTestUtils.toObject(data: data, toType: [AnyCodable].self)

            print(decode)
            //swiftlint:disable:next force_cast
            let result = decode.first?.value as! String

            XCTAssertNotNil(decode.description)
            XCTAssertEqual(result, "test")
        } catch {
            XCTFail("failed")
        }
    }

    func testDictionary() {
        let data = ["model": ["test": ["test": "123", "bla": 123]]]
        do {
            let decode = try DecodeTestUtils.toObject(data: data, toType: [String: AnyCodable].self)

            let result = decode["model"]?.value

            XCTAssertNotNil(decode.description)
            XCTAssertNotNil(result)
        } catch {
            XCTFail("failed")
        }
    }

    func testArray() {
        let data: [Any] = ["model", "dasd"]
        do {
            let decode = try DecodeTestUtils.toObject(data: data, toType: [AnyCodable].self)

            let dataCompare: [AnyCodable] = ["model", "dasd1"]

            let result = decode

            if result == dataCompare {
                XCTAssert(true)
            }

            XCTAssertNotNil(decode.description)
            XCTAssertEqual(result.count, 2)
        } catch {
            XCTFail("failed")
        }
    }

    func testInt() {

        let data = [123]
        do {
            let decode = try DecodeTestUtils.toObject(data: data, toType: [AnyCodable].self)

            //swiftlint:disable:next force_cast
            let result = decode.first?.value as! Int

            let testEquatableValue: AnyCodable = 123
            if decode.first! == testEquatableValue {
                XCTAssert(true)
            }

            XCTAssertNotNil(decode.description)
            XCTAssertEqual(result, 123)
        } catch {
            XCTFail("failed")
        }
    }

    func testBool() {

        let data = [true]
        do {
            let decode = try DecodeTestUtils.toObject(data: data, toType: [AnyCodable].self)

            //swiftlint:disable:next force_cast
            let result = decode.first?.value as! Bool

            let testEquatableValue: AnyCodable = true
            if decode.first! == testEquatableValue {
                XCTAssert(true)
            }
            XCTAssertNotNil(decode.description)

            XCTAssertEqual(result, true)
        } catch {
            XCTFail("failed")
        }
    }

    func testNil() {
        let data = [nil] as [Any?]
        do {
            let decode = try DecodeTestUtils.toObject(data: data, toType: [AnyCodable].self)

            let result = decode.first ?? nil

            XCTAssertNotNil(decode.description)
            XCTAssertEqual(result, "null")
        } catch {
            XCTFail("failed")
        }
    }

    func testDouble() {
        let data = [3.3]
        do {
            let decode = try DecodeTestUtils.toObject(data: data, toType: [AnyCodable].self)

            //swiftlint:disable:next force_cast
            let result = decode.first?.value as! Double

            let testEquatableValue: AnyCodable = 3.3
            if decode.first == testEquatableValue {
                XCTAssert(true)
            }

            XCTAssertNotNil(decode.description)
            XCTAssertEqual(result, 3.3)
        } catch {
            XCTFail("failed")
        }
    }

    func testCompareDic() {
        let oneDic: [String: AnyCodable] = ["dasd": 123, "ddx": true]
        let twoDic: [String: AnyCodable] = ["dasd": 123, "ddx": false]

        if oneDic != twoDic {
            XCTAssert(true)
        } else {
            XCTFail("failed")
        }
    }

    func testCompareArray() {
        let oneDic: [AnyCodable] = [123, true]
        let twoDic: [AnyCodable] = [123, false]

        if oneDic != twoDic {
            XCTAssert(true)
        } else {
            XCTFail("failed")
        }
    }

    func testEquatableFalse() {
        let fromInt: AnyCodable = 123
        let withString: AnyCodable = "123"

        if fromInt != withString {
            XCTAssert(true)
        } else {
            XCTFail("failed")
        }
    }

    func testEncodeInt() {
        let data = [AnyCodable(integerLiteral: 1), AnyCodable(integerLiteral: 2)]

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssertEqual(jsonString, "[1,2]")
    }

    func testEncodeBool() {
        let data = [AnyCodable(booleanLiteral: true), AnyCodable(booleanLiteral: false)]

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssertEqual(jsonString, "[true,false]")
    }

    func testEncodeDouble() {
        let data = [AnyCodable(floatLiteral: 1.5), AnyCodable(floatLiteral: 3.5)]

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssertEqual(jsonString, "[1.5,3.5]")
    }

    func testEncodeString() {
        let data = [AnyCodable(extendedGraphemeClusterLiteral: "test1"), AnyCodable(extendedGraphemeClusterLiteral: "test2")]

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssertEqual(jsonString, "[\"test1\",\"test2\"]")
    }

    func testEncodeDate() {
        let date: Date = Date()
        let data = [AnyCodable(date)]

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssertNotNil(jsonString)
    }

    func testEncodeURL() {
        let url: URL = URL(fileURLWithPath: "google.com")
        let data = [AnyCodable(url)]

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssert(jsonString!.contains("google.com"))
    }

    func testEncodeArray() {
        let array = [1,2,3,4,5]
        let data = [AnyCodable(array)]

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssertEqual(jsonString, "[[1,2,3,4,5]]")
    }

    func testEncodeDictionary() {
        let dic = ["a": 1, "b": 2, "c": 3]
        let data = [AnyCodable(dic)]

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssertNotNil(jsonString)
    }

    func testEncodeNil() {
        let data = [AnyCodable(nil)]

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssertEqual(jsonString, "[null]")
    }

    func testEncodeError() {
        let data = [AnyCodable(GigyaResponseModel(statusCode: .unknown, errorCode: 0, callId: "", errorMessage: "", sessionInfo: nil, requestData: nil))]

        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(data)
            let _ = String(data: jsonData, encoding: .utf8)

            XCTFail()
        } catch let error {
            XCTAssertEqual(error.localizedDescription, "The data couldn’t be written because it isn’t in the correct format.")
        }


    }
}

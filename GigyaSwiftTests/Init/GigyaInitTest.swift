//
//  GigyaInitTest.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 27/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class GigyaInitTest: XCTestCase {

    var ioc: GigyaContainerUtils?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ioc = GigyaContainerUtils()

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        GigyaSwift.removeStoredInstance()
    }

    func testInitWithOutSchema() {
        let gigya = GigyaSwift.sharedInstance()

        let className = String(describing: gigya.self)

        XCTAssertEqual(className, "GigyaSwift.GigyaCore<GigyaSwift.GigyaAccount>")
    }

    func testInitWithSchema() {
        let gigya = GigyaSwift.sharedInstance(UserDataModel.self)

        let className = String(describing: gigya.self)

        XCTAssertEqual(className, "GigyaSwift.GigyaCore<GigyaSwiftTests.UserDataModel>")
    }

    func testInitWithWrongSchema() {
        GigyaSwift.sharedInstance(UserDataModel.self)

        expectFatalError(expectedMessage: "[GigyaSwift]: You need to use:  UserDataModel") {
            GigyaSwift.sharedInstance()
        }
    }

    func testInitWithOutApiKey() {
        expectFatalError(expectedMessage: "[GigyaSwift]: please make sure you call 'initWithApi' or add apiKey to plist file ") {
            GigyaSwift.sharedInstance().initWithApi(apiKey: "")
        }
    }

//    func testParsePlist() {
//        if let plist = DecodeEncodeUtils.parsePlistConfig() {
//            XCTAssertNotNil(plist)
//        } else {
//            XCTFail()
//        }
//    }

    // Dependencies tests
    func testConfigDependency() {
        let config = GigyaSwift.sharedInstance().container?.resolve(GigyaConfig.self)
        XCTAssertNotNil(config)
    }

    func testGigyaApiDependency() {
        let gigyaApi = GigyaSwift.sharedInstance().container?.resolve(IOCGigyaWrapperProtocol.self)
        XCTAssertNotNil(gigyaApi)
    }

    func testAccountServiceDependency() {
        let accountService = GigyaSwift.sharedInstance().container?.resolve(IOCAccountServiceProtocol.self)
        XCTAssertNotNil(accountService)
    }

    func testSessionServiceDependency() {
        let sessionService = GigyaSwift.sharedInstance().container?.resolve(IOCSessionServiceProtocol.self)
        XCTAssertNotNil(sessionService)
    }

    func testApiServiceDependency() {
        let apiService = GigyaSwift.sharedInstance().container?.resolve(IOCApiServiceProtocol.self)
        XCTAssertNotNil(apiService)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

//extension DecodeEncodeUtils {
//    static func parsePlistConfig() -> PlistConfig? {
//        return PlistConfig(apiKey: "123", apiDomain: "")
//    }
//}

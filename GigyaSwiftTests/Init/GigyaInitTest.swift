//
//  GigyaInitTest.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 27/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class GigyaInitTest: XCTestCase {

    var ioc: GigyaContainerUtils?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ioc = GigyaContainerUtils()

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        Gigya.removeStoredInstance()
    }

    func testInitWithOutSchema() {
        let gigya = Gigya.sharedInstance()

        let className = String(describing: gigya.self)

        XCTAssertEqual(className, "Gigya.GigyaCore<Gigya.GigyaAccount>")
    }

    func testInitWithSchema() {
        let gigya = Gigya.sharedInstance(UserDataModel.self)

        let className = String(describing: gigya.self)

        XCTAssertEqual(className, "Gigya.GigyaCore<GigyaSwiftTests.UserDataModel>")
    }

    func testInitWithWrongSchema() {
        Gigya.sharedInstance(UserDataModel.self)

        expectFatalError(expectedMessage: "[Gigya]: You need to use:  UserDataModel") {
            Gigya.sharedInstance()
        }
    }

    func testInitWithOutApiKey() {
        expectFatalError(expectedMessage: "[Gigya]: please make sure you call 'initWithApi' or add apiKey to plist file ") {
            Gigya.sharedInstance().initWithApi(apiKey: "")
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
        let config = Gigya.sharedInstance().container?.resolve(GigyaConfig.self)
        XCTAssertNotNil(config)
    }

    func testGigyaApiDependency() {
        let gigyaApi = Gigya.sharedInstance().container?.resolve(IOCGigyaWrapperProtocol.self)
        XCTAssertNotNil(gigyaApi)
    }

    func testAccountServiceDependency() {
        let accountService = Gigya.sharedInstance().container?.resolve(IOCAccountServiceProtocol.self)
        XCTAssertNotNil(accountService)
    }

    func testSessionServiceDependency() {
        let sessionService = Gigya.sharedInstance().container?.resolve(IOCSessionServiceProtocol.self)
        XCTAssertNotNil(sessionService)
    }

    func testApiServiceDependency() {
        let apiService = Gigya.sharedInstance().container?.resolve(IOCApiServiceProtocol.self)
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

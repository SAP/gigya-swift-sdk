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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let ioc = GigyaContainerUtils.shared
        Gigya.container = ioc.container

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        Gigya.removeStoredInstance()

        Gigya.container = nil
    }

    func testInitWithOutSchema() {
        let gigya = Gigya.sharedInstance()

        let className = String(describing: gigya.self)

        XCTAssertEqual(className, "Gigya.GigyaCore<Gigya.GigyaAccount>")
    }

    func testInitWithSchema() {
        Gigya.removeStoredInstance()

        let ioc = GigyaContainerUtils.shared
        ioc.registerDependencie(UserDataModel.self)
        Gigya.container = ioc.container

        let gigya = Gigya.sharedInstance(UserDataModel.self)

        let className = String(describing: gigya.self)

        XCTAssertEqual(className, "Gigya.GigyaCore<GigyaSwiftTests.UserDataModel>")
    }

    func testInitWithWrongSchema() {
        Gigya.removeStoredInstance()

        let ioc = GigyaContainerUtils.shared
        ioc.registerDependencie(UserDataModel.self)
        Gigya.container = ioc.container

        Gigya.sharedInstance(UserDataModel.self)

        expectFatalError(expectedMessage: "[Gigya]: Gigya instance was originally created with a different GigyaAccountProtocol: UserDataModel") {
            Gigya.sharedInstance()
        }
    }
//
//    func testInitWithOutApiKey() {
//        expectFatalError(expectedMessage: "[Gigya]: please make sure you call 'initWithApi' or add apiKey to plist file ") {
//            Gigya.sharedInstance().initFor(apiKey: "")
//        }
//    }

    // Dependencies tests
    func testConfigDependency() {

        let config = Gigya.container?.resolve(GigyaConfig.self)
        XCTAssertNotNil(config)
    }

    func testAccountServiceDependency() {
        let accountService = Gigya.container?.resolve(AccountServiceProtocol.self)
        XCTAssertNotNil(accountService)
    }

    func testSessionServiceDependency() {
        let sessionService = Gigya.container?.resolve(SessionServiceProtocol.self)
        XCTAssertNotNil(sessionService)
    }

    func testApiServiceDependency() {
        let apiService = Gigya.container?.resolve(ApiServiceProtocol.self)
        XCTAssertNotNil(apiService)
    }

}

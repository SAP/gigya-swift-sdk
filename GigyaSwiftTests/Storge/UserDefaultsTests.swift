//
//  UserDefaultsTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 23/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class UserDefaultsTests: XCTestCase {
    let ioc = GigyaContainerUtils()
    var config: GigyaConfig?

    override func setUp() {
        config = ioc.container.resolve(GigyaConfig.self)

        UserDefaults.standard.set("testSaveGmid", forKey: InternalConfig.Storage.GMID)
        UserDefaults.standard.set("testSaveUcid", forKey: InternalConfig.Storage.UCID)

        UserDefaults.standard.synchronize()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: InternalConfig.Storage.GMID)
        UserDefaults.standard.removeObject(forKey: InternalConfig.Storage.UCID)
    }

    func testGetGmid() {
        if let gmid = config?.gmid {
            XCTAssertNotNil(gmid)
        } else {
            XCTFail()
        }
    }

    func testGetUcid() {
        if let ucid = config?.ucid {
            XCTAssertNotNil(ucid)
        } else {
            XCTFail()
        }
    }

    func testGetFail() {
        tearDown()

        if let _ = config?.gmid {
            XCTFail()
        } else {
            XCTAssert(true)
        }
    }
    
}

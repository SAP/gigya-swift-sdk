//
//  UserDefaultsTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 23/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class UserDefaultsTests: XCTestCase {
    let ioc = GigyaContainerUtils.shared
    var config: GigyaConfig?
    var persistenceService: PersistenceService?

    override func setUp() {
        config = ioc.container.resolve(GigyaConfig.self)
        persistenceService = ioc.container.resolve(PersistenceService.self)
        UserDefaults.standard.set("testSaveGmid", forKey: InternalConfig.Storage.GMID)
        UserDefaults.standard.set("testSaveUcid", forKey: InternalConfig.Storage.UCID)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: InternalConfig.Storage.GMID)
        UserDefaults.standard.removeObject(forKey: InternalConfig.Storage.UCID)
    }

    func testGetGmid() {
        if let gmid = persistenceService?.gmid {
            XCTAssertNotNil(gmid)
        } else {
            XCTFail()
        }
    }

    func testGetUcid() {
        if let ucid = persistenceService?.ucid {
            XCTAssertNotNil(ucid)
        } else {
            XCTFail()
        }
    }

    func testGetFail() {
        tearDown()

        if let _ = persistenceService?.gmid {
            XCTFail()
        } else {
            XCTAssert(true)
        }
    }
    
}

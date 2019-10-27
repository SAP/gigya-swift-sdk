//
//  URLSession.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 25/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class URLSessionTests: XCTestCase {

    override func setUp() {

    }

    func testRequest() {
        let config = GigyaConfig()
        let accountService = AccountService()
        let adapter = NetworkAdapter(config: config, persistenceService: PersistenceService(), sessionService: SessionService(config: config, persistenceService: PersistenceService(), accountService: accountService, keychainHelper: KeychainStorageFactory(plistFactory: PlistConfigFactory())))

        adapter.send(model: ApiRequestModel(method: "test")) { (data, error) in

        }
    }
}


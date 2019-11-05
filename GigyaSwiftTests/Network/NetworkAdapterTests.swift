//
//  NetworkAdapterTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 26/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class NetworkAdapterTests: XCTestCase {

    override func setUp() {

    }
    
    func testRequest() {
        let config = GigyaConfig()
        let accountService = AccountService()
        config.apiKey = "123"

        let networkProvider = NetworkProvider(config: config, persistenceService: PersistenceService(), sessionService: SessionService(config: config, persistenceService: PersistenceService(), accountService: accountService, keychainHelper: KeychainStorageFactory(plistFactory: PlistConfigFactory())))
        
        let adapter = NetworkAdapter(networkProvider: networkProvider, queueHelper: NetworkBlockingQueueUtils())

        adapter.send(model: ApiRequestModel(method: "test")) { (data, error) in
            
        }
    }
}

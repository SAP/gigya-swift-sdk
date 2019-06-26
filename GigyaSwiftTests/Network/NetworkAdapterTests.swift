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
        Gigya.sharedInstance().initWithApi(apiKey: "123")
    }
    
    func testRequest() {
        let adapter = NetworkAdapter()

        adapter.send(model: ApiRequestModel(method: "test")) { (data, error) in
            
        }
    }
}

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

    func testInstance() {
        let session = URLSession.sharedInternal
        XCTAssertFalse(session.configuration.httpShouldSetCookies)
    }
}


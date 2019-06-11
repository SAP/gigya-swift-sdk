//
//  FakeNavigationAction.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 02/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit

class FakeNavigationAction: WKNavigationAction {
    let testRequest: URLRequest
    override var request: URLRequest {
        return testRequest
    }

    override var navigationType: WKNavigationType {
        return .other
    }

    init(testRequest: URLRequest) {
        self.testRequest = testRequest
        
        super.init()
    }
}

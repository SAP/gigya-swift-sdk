//
//  PluginViewControllerTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 05/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import XCTest
import WebKit
@testable import Gigya

class PluginViewControllerTests: XCTestCase {
    let ioc = GigyaContainerUtils()
    var gigya = Gigya.sharedInstance()

    var config: GigyaConfig {
        return ioc.container.resolve(GigyaConfig.self)!
    }

    var businessApi: IOCBusinessApiServiceProtocol {
        return ioc.container.resolve(IOCBusinessApiServiceProtocol.self)!
    }

    var sessionService: IOCSessionServiceProtocol {
        return ioc.container.resolve(IOCSessionServiceProtocol.self)!
    }


    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        Gigya.sharedInstance().container = ioc.container

        Gigya.sharedInstance().initFor(apiKey: "123")

        ResponseDataTest.clientID = nil
        ResponseDataTest.resData = nil
        ResponseDataTest.providerToken = nil
        ResponseDataTest.providerSecret = nil
        ResponseDataTest.providerError = nil


    }

    func testLoad() {
        let plugin = PluginViewController<GigyaAccount>(config: config, sessionService: sessionService, businessApiService: businessApi) { event in }

        let contentController = WKUserContentController()

        let data = ["callbackID": "123", "action": "test", "params": ["action": "123"]] as [String : Any]
        let message = FakeWKScriptMessage(data: data)

        plugin.userContentController(contentController, didReceive: message)

    }

}

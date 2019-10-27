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
    let ioc = GigyaContainerUtils.shared

    var config: GigyaConfig {
        return ioc.container.resolve(GigyaConfig.self)!
    }

    var persistenceService: PersistenceService {
        return ioc.container.resolve(PersistenceService.self)!
    }

    var businessApi: BusinessApiServiceProtocol {
        return ioc.container.resolve(BusinessApiServiceProtocol.self)!
    }

    var sessionService: SessionServiceProtocol {
        return ioc.container.resolve(SessionServiceProtocol.self)!
    }


    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil

        Gigya.gigyaContainer = GigyaIOCContainer<GigyaAccount>()
        Gigya.gigyaContainer?.container = ioc.container

        Gigya.sharedInstance(UserDataModel.self).initFor(apiKey: "123")

        ResponseDataTest.clientID = nil
        ResponseDataTest.resData = nil
        ResponseDataTest.providerToken = nil
        ResponseDataTest.providerSecret = nil
        ResponseDataTest.providerError = nil


    }

    func testLoad() {
        let webBridge = GigyaWebBridge<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi)

        let plugin = PluginViewController(webBridge: webBridge) { (event) in }

        let contentController = WKUserContentController()

        let data = ["callbackID": "123", "action": "test", "params": ["action": "123"]] as [String : Any]
        let message = FakeWKScriptMessage(data: data)

//        plugin.contentController(contentController, didReceive: message)

    }

}

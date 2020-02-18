//
//  PluginViewWrapperTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 04/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
import WebKit
@testable import Gigya

class PluginViewWrapperTests: XCTestCase {
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

        config.apiKey = "123"

//        Gigya.gigyaContainer = GigyaIOCContainer<GigyaAccount>()
//        Gigya.gigyaContainer?.container = ioc.container
//
//
//        Gigya.sharedInstance(UserDataModel.self).initFor(apiKey: "123")

        ResponseDataTest.clientID = nil
        ResponseDataTest.resData = nil
        ResponseDataTest.providerToken = nil
        ResponseDataTest.providerSecret = nil
        ResponseDataTest.providerError = nil

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

    }

    func testPluginGetHtml() {
        let plugin = "accounts.screenSet"

        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { _ in }

        let webBridge = GigyaWebBridge<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi)
        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi, webBridge: webBridge, plugin: plugin, params: [:], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        let html = wrapper.getHtml(plugin)

        XCTAssert(!html.isEmpty)

    }

    func testPluginGetHtmlNoneApiKey() {
        config.apiKey = nil
        
        let plugin = "accounts.screenSet"

        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { _ in }
        let webBridge = GigyaWebBridge<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi)

        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi, webBridge: webBridge, plugin: plugin, params: [:], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        let html = wrapper.getHtml(plugin)

        XCTAssert(html.isEmpty)

    }

    func testPluginHtmlCheckCommentsUI() {
        let plugin = "accounts.screenSet"

        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { _ in }
        let webBridge = GigyaWebBridge<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi)

        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi, webBridge: webBridge, plugin: plugin, params: ["commentsUI": "true","version": -1], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        let html = wrapper.getHtml(plugin)

        XCTAssert(html.contains("commentsUI"))

    }

    func testPluginHtmlRatingAndShowButton() {
        let plugin = "accounts.screenSet"

        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { _ in }

        let webBridge = GigyaWebBridge<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi)
        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi, webBridge: webBridge, plugin: plugin, params: ["RatingUI": "true","showCommentButton": "true"], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        let html = wrapper.getHtml(plugin)

        XCTAssert(html.contains("RatingUI"))

    }

    func testPluginEventOnLoginTest() {
        // This is an example of a functional test case.
        let responseDic: [String: Any] = ["callId": "fasfsaf", "errorCode": 0, "statusCode": 200]
        //swiftlint:disable:next force_try
        let objData = try! JSONSerialization.data(withJSONObject: responseDic, options: .prettyPrinted)

        ResponseDataTest.providerToken = "dasf"
        ResponseDataTest.providerSecret = "dasdas"
        ResponseDataTest.resData = objData as NSData


        let plugin = "accounts.screenSet"

        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { result in
            switch result {
            case .onLogin(let account):
                XCTAssertNotNil(account)
            default:
                XCTFail()
            }
        }

        let webBridge = GigyaWebBridge<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi)
        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi, webBridge: webBridge, plugin: plugin, params: [:], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        webBridge.userContentController(webBridge.contentController, didReceive: OnLoginCustomWKScriptMessage())


    }


    func testPluginEventRequestTest() {
        // This is an example of a functional test case.
        let responseDic: [String: Any] = ["callId": "fasfsaf", "errorCode": 5, "statusCode": 200]
        //swiftlint:disable:next force_try
        let objData = try! JSONSerialization.data(withJSONObject: responseDic, options: .prettyPrinted)

        ResponseDataTest.resData = objData as NSData


        let plugin = "accounts.screenSet"

        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { result in
            switch result {
            case .error(let event):
                XCTAssertNotNil(event)
            default:
                XCTFail()
            }
        }

        let webBridge = GigyaWebBridge<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi)
        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi, webBridge: webBridge, plugin: plugin, params: [:], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        webBridge.userContentController(webBridge.contentController, didReceive: ReqCustomWKScriptMessage())


    }


    func testPluginEventOnLogoutTest() {

        sessionService.setSession(SessionInfoModel(sessionToken: "test-logout", sessionSecret: "test-logout", sessionExpiration: ""))

        print(sessionService.isValidSession())
        // This is an example of a functional test case.
        let responseDic: [String: Any] = ["callId": "fasfsaf", "errorCode": 0, "statusCode": 200]
        //swiftlint:disable:next force_try
        let objData = try! JSONSerialization.data(withJSONObject: responseDic, options: .prettyPrinted)

        ResponseDataTest.providerToken = "dasf"
        ResponseDataTest.providerSecret = "dasdas"
        ResponseDataTest.resData = objData as NSData


        let plugin = "accounts.screenSet"

        let expectation = self.expectation(description: "checkUpdatePush111")


        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { result in

            switch result {
            case .onLogout:
                expectation.fulfill()
                XCTAssertFalse(self.sessionService.isValidSession())
            default:
                XCTFail()
            }
        }

        let webBridge = GigyaWebBridge<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi)
        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApi, webBridge: webBridge, plugin: plugin, params: [:], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        webBridge.userContentController(webBridge.contentController, didReceive: OnLogoutCustomWKScriptMessage())

        waitForExpectations(timeout: 5, handler: nil)
    }

}


class OnLoginCustomWKScriptMessage: WKScriptMessage {
    override var name: String {
        return "123"
    }

    override var body: Any {
        return ["action": "send_oauth_request","params": "callbackID=123&params=provider%3Dfacebook", "method": GigyaDefinitions.API.socialLogin]
    }
}

class OnLogoutCustomWKScriptMessage: WKScriptMessage {
    override var name: String {
        return "123"
    }

    override var body: Any {
        return ["action": "send_oauth_request","params": "callbackID=123&params=provider%3Dfacebook", "method": GigyaDefinitions.API.logout]
    }
}

class ReqCustomWKScriptMessage: WKScriptMessage {
    override var name: String {
        return "123"
    }

    override var body: Any {
        return ["action": "send_request","params": "callbackID=123&params=provider%3Dfacebook", "method": "GigyaDefinitions.API.socialLogin"]
    }
}



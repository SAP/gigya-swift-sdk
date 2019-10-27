//
//  WebViewWrapper.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 02/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
import WebKit
@testable import Gigya

class WebViewWrapperTests: XCTestCase {

    var webViewWrapper: WebLoginWrapper = WebLoginWrapper()

    var config = GigyaConfig()

    var persistenceService = PersistenceService()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        config.apiDomain = "us1.gigya.com"

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetUrlSuccess() {
        config.apiKey = "test_valid_key"

        webViewWrapper = WebLoginWrapper(config: config, persistenceService: persistenceService, providerType: .google)

        let url = webViewWrapper.getUrl()
        if url?.absoluteString.contains("test_valid_key") == true {
            XCTAssert(true)
        } else {
            XCTFail()
        }
    }

    func testGetUrlFail() {
        config.apiKey = "§§urlNotVlid*&%#$@/.,\\\\//d„„23"
        config.apiDomain = "us1.gigya.com"

        webViewWrapper = WebLoginWrapper(config: config, persistenceService: persistenceService, providerType: .google)

        XCTAssertNil(webViewWrapper.getUrl()?.absoluteString) 
    }

    func testGetUrlWithoutKeyDomain() {
        config.apiKey = nil
        config.apiDomain = ""

        webViewWrapper = WebLoginWrapper(config: config, persistenceService: persistenceService, providerType: .google)

        XCTAssert(webViewWrapper.getUrl()!.absoluteString.contains("client_id=&"))
    }

    func testLoginUserCancel() {
        config.apiKey = "test_valid_key"
        config.apiDomain = "us1.gigya.com"

        webViewWrapper = WebLoginWrapper(config: config, persistenceService: persistenceService, providerType: .google)

        let vc = UIViewController()

        webViewWrapper.login(params: nil, viewController: vc, completion: { (json, error) in
            XCTAssert(error?.contains("sign in cancelled") ?? false)
        })

        webViewWrapper.webViewController?.dismissView()
    }

    func testLoginDelegate() {
        config.apiKey = "test_valid_key"
        config.apiDomain = "us1.gigya.com"

        webViewWrapper = WebLoginWrapper(config: config, persistenceService: persistenceService, providerType: .google)

        var receivedPolicy: WKNavigationActionPolicy?
        let fakeAction = FakeNavigationAction(testRequest: URLRequest(url: URL(string: "https://socialize.us1.gigya.com/socialize.login?status=ok&access_token=123&x_access_token_secret=123")!))
        let vc = UIViewController()

        webViewWrapper.login(params: nil, viewController: vc) { (result, error) in
            XCTAssertNotNil(result)
        }

        print(receivedPolicy as Any)
    webViewWrapper.webViewController?.webView.navigationDelegate?.webView?(webViewWrapper.webViewController!.webView, decidePolicyFor: fakeAction, decisionHandler: { receivedPolicy = $0 })
    }

    func testLoginDelegateFail() {
        config.apiKey = "test_valid_key"
        config.apiDomain = "us1.gigya.com"
        let vc = UIViewController()

        webViewWrapper = WebLoginWrapper(config: config, persistenceService: persistenceService, providerType: .google)

        var receivedPolicy: WKNavigationActionPolicy?
        let fakeAction = FakeNavigationAction(testRequest: URLRequest(url: URL(string: "https://socialize.us1.gigya.com/socialize.login?status=none&access_token=123&x_access_token_secret=123")!))
        webViewWrapper.login(params: nil, viewController: vc) { (result, error) in
            XCTAssertNotNil(error)
        }

        print(receivedPolicy)

        webViewWrapper.webViewController?.webView.navigationDelegate?.webView?(webViewWrapper.webViewController!.webView, decidePolicyFor: fakeAction, decisionHandler: { receivedPolicy = $0 })

    }
}

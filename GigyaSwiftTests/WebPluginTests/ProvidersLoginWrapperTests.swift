//
//  ProvidersLoginWrapper.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 25/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
import WebKit
@testable import Gigya

class ProvidersLoginWrapperTests: XCTestCase {

    var webViewWrapper: ProvidersLoginWrapper = ProvidersLoginWrapper(config: GigyaConfig(), providers: [.google])

    var config = GigyaConfig()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        config.apiDomain = "us1.gigya.com"

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetUrlSuccess() {
        config.apiKey = "test_valid_key"

        webViewWrapper = ProvidersLoginWrapper(config: config, providers: [.google, .facebook])

        let url = webViewWrapper.getUrl(params: [:])
        if url?.absoluteString.contains("test_valid_key") == true {
            XCTAssert(true)
            webViewWrapper.dismiss()
        } else {
            XCTFail()
        }
    }

    func testGetUrlFail() {
        config.apiKey = "§§urlNotVlid*&%#$@/.,\\\\//d„„23"
        config.apiDomain = "us1.gigya.com"

        webViewWrapper = ProvidersLoginWrapper(config: config, providers: [.google, .facebook])

        XCTAssertNil(webViewWrapper.getUrl(params: [:])?.absoluteString)
    }

    func testGetUrlWithoutKeyDomain() {
        config.apiKey = nil
        config.apiDomain = ""

        webViewWrapper = ProvidersLoginWrapper(config: config, providers: [.google, .facebook])

        XCTAssert(webViewWrapper.getUrl(params: [:])!.absoluteString.contains("apikey=&"))
    }

    func testLoginUserCancel() {
        config.apiKey = "test_valid_key"
        config.apiDomain = "us1.gigya.com"

        webViewWrapper = ProvidersLoginWrapper(config: config, providers: [.google, .facebook])

        let vc = UIViewController()

        webViewWrapper.show(params: [:], viewController: vc) { (json, error) in
            XCTAssert(error?.contains("sign in cancelled") ?? false)
        }

        webViewWrapper.webViewController?.dismissView()
    }

    func testLoginDelegate() {
        config.apiKey = "test_valid_key"
        config.apiDomain = "us1.gigya.com"

        webViewWrapper = ProvidersLoginWrapper(config: config, providers: [.google, .facebook])

        var receivedPolicy: WKNavigationActionPolicy?
        let fakeAction = FakeNavigationAction(testRequest: URLRequest(url: URL(string: "https://socialize.us1.gigya.com/socialize.login?status=ok&access_token=123&x_access_token_secret=123&provider=googleplus")!))
        let vc = UIViewController()

        webViewWrapper.show(params: [:], viewController: vc) { (result, error) in
            XCTAssertNotNil(result)
        }

        print(receivedPolicy as Any)
        webViewWrapper.webViewController?.webView.navigationDelegate?.webView?(webViewWrapper.webViewController!.webView, decidePolicyFor: fakeAction, decisionHandler: { receivedPolicy = $0 })
    }

    func testLoginDelegateFail() {
        config.apiKey = "test_valid_key"
        config.apiDomain = "us1.gigya.com"
        let vc = UIViewController()

        webViewWrapper = ProvidersLoginWrapper(config: config, providers: [.google, .facebook])

        var receivedPolicy: WKNavigationActionPolicy?
        let fakeAction = FakeNavigationAction(testRequest: URLRequest(url: URL(string: "https://socialize.us1.gigya.com/socialize.login?status=none&access_token=123&x_access_token_secret=123")!))
        webViewWrapper.show(params: [:], viewController: vc) { (result, error) in
            XCTAssertNotNil(error)
        }

        print(receivedPolicy)

        webViewWrapper.webViewController?.webView.navigationDelegate?.webView?(webViewWrapper.webViewController!.webView, decidePolicyFor: fakeAction, decisionHandler: { receivedPolicy = $0 })

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

//
//  PluginViewWrapperTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 04/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class PluginViewWrapperTests: XCTestCase {
    let ioc = GigyaContainerUtils()
    var gigya = GigyaSwift.sharedInstance()

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
        GigyaSwift.sharedInstance().container = ioc.container

        GigyaSwift.sharedInstance().initWithApi(apiKey: "123")

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

        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, sessionService: sessionService, businessApiService: businessApi, plugin: plugin, params: [:], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        let html = wrapper.getHtml(plugin)

        XCTAssert(!html.isEmpty)

    }

    func testPluginGetHtmlNoneApiKey() {
        config.apiKey = nil
        
        let plugin = "accounts.screenSet"

        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { _ in }

        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, sessionService: sessionService, businessApiService: businessApi, plugin: plugin, params: [:], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        let html = wrapper.getHtml(plugin)

        XCTAssert(html.isEmpty)

    }

    func testPluginHtmlCheckCommentsUI() {
        let plugin = "accounts.screenSet"

        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { _ in }

        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, sessionService: sessionService, businessApiService: businessApi, plugin: plugin, params: ["commentsUI": "true","version": -1], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        let html = wrapper.getHtml(plugin)

        XCTAssert(html.contains("commentsUI"))

    }

    func testPluginHtmlRatingAndShowButton() {
        let plugin = "accounts.screenSet"

        let complete: (GigyaPluginEvent<GigyaAccount>) -> Void = { _ in }

        let wrapper = PluginViewWrapper<GigyaAccount>(config: config, sessionService: sessionService, businessApiService: businessApi, plugin: plugin, params: ["RatingUI": "true","showCommentButton": "true"], completion: complete)

        let vc = FakeUIViewController()
        wrapper.presentPluginController(viewController: vc, dataType: GigyaAccount.self, screenSet: plugin)

        let html = wrapper.getHtml(plugin)

        XCTAssert(html.contains("RatingUI"))

    }
}

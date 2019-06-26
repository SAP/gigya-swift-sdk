//
//  GoogleTest.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import XCTest
@testable import Gigya

class WebProviderLoginTests: XCTestCase {
    let ioc = GigyaContainerUtils()
    var gigya = Gigya.sharedInstance()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        Gigya.sharedInstance().container = ioc.container

        Gigya.sharedInstance().initWithApi(apiKey: "123")

        ResponseDataTest.clientID = nil
        ResponseDataTest.resData = nil
        ResponseDataTest.providerToken = nil
        ResponseDataTest.providerSecret = nil
        ResponseDataTest.providerError = nil

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginSuccess() {
        let viewController = UIViewController()

        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData
        ResponseDataTest.clientID = "123"
        ResponseDataTest.providerToken = "123"
        ResponseDataTest.providerSecret = "123"

        Gigya.sharedInstance().login(with: .yahoo, viewController: viewController, params: ["testParam": "test"]) { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data )
            case .failure(let error):
                XCTFail("Fail: \(error)")
            }
        }
    }

    func testLoginNoneToken() {
        let viewController = UIViewController()
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.clientID = "123"
        ResponseDataTest.resData = jsonData

        Gigya.sharedInstance().login(with: .yahoo, viewController: viewController) { (result) in
            switch result {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                if case .providerError(let data) = error.error {
                    XCTAssertEqual(data, "token no available")
                }
            }
        }
    }

    func testLoginWithError() {

        let viewController = UIViewController()

        let error = NSError(domain: "gigya", code: 400093, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.clientID = "123"
        ResponseDataTest.error = error
        ResponseDataTest.providerToken = "123"
        ResponseDataTest.providerSecret = "123"

        Gigya.sharedInstance().login(with: .yahoo, viewController: viewController) { (result) in
            switch result {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                if case .providerError(let data) = error.error {
                    XCTAssertEqual(data, "The operation couldn’t be completed. (gigya error 400093.)")
                }
            }
        }
    }

    func testLoginProviderError() {

        let viewController = UIViewController()

        let error = NSError(domain: "gigya", code: 400093, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.clientID = "123"
        ResponseDataTest.error = error
        ResponseDataTest.providerToken = "123"
        ResponseDataTest.providerSecret = "123"
        ResponseDataTest.providerError = "The operation couldn’t be completed. (gigya error 400093.)"

        Gigya.sharedInstance().login(with: .yahoo, viewController: viewController) { (result) in
            switch result {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                if case .providerError(let data) = error.error {
                    XCTAssertEqual(data, "The operation couldn’t be completed. (gigya error 400093.)")
                }
            }
        }
    }

    func testAddConnection() {
        let viewController = UIViewController()

        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData
        ResponseDataTest.clientID = "123"
        ResponseDataTest.providerToken = "123"
        ResponseDataTest.providerSecret = "123"

        Gigya.sharedInstance().addConnection(provider: .yahoo, viewController: viewController, params: ["testParam": "test"]) { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data )
            case .failure(let error):
                XCTFail("Fail: \(error)")
            }
        }
    }

    func testWebLoginIsSession() {
        XCTAssert(WebLoginProvider.isAvailable())
    }

    func testWebLoginGetSession() {
        let businessApi = ioc.container.resolve(IOCBusinessApiServiceProtocol.self)!
        let sessionService = ioc.container.resolve(IOCSessionServiceProtocol.self)!

        let provider = WebLoginProvider(sessionService: sessionService, provider: WebProviderWrapperMock(), delegate: businessApi as! BusinessApiDelegate)

        XCTAssertEqual(provider.getProviderSessions(token: "", expiration: ""), "")

    }

}

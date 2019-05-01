//
//  FacebookTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class FacebookTests: XCTestCase {
    let ioc = GigyaContainerUtils()
    var gigya = GigyaSwift.sharedInstance()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        GigyaSwift.sharedInstance().container = ioc.container

        GigyaSwift.sharedInstance().initWithApi(apiKey: "123")

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
        ResponseDataTest.providerToken = "123"

        GigyaSwift.sharedInstance().login(with: .facebook, viewController: viewController, params: ["testParam": "test"]) { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
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

        GigyaSwift.sharedInstance().login(with: .facebook, viewController: viewController) { (result) in
            switch result {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                if case .providerError(let data) = error {
                    XCTAssertEqual(data, "Id token no available")
                }
            }
        }
    }

    func testLoginWithError() {
        let viewController = UIViewController()

        let error = NSError(domain: "gigya", code: 400093, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.clientID = "123"
        ResponseDataTest.error = error

        GigyaSwift.sharedInstance().login(with: .facebook, viewController: viewController) { (result) in
            switch result {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                if case .providerError(let data) = error {
                    XCTAssertEqual(data, "The operation couldn’t be completed. (gigya error 400093.)")
                }
            }
        }
    }
}

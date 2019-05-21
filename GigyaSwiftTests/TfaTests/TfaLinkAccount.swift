//
//  TfaLinkAccount.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 20/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class TfaLinkAccount: XCTestCase {
    var ioc: GigyaContainerUtils?

    var businessApi: IOCBusinessApiServiceProtocol?
    
    override func setUp() {
        ioc = GigyaContainerUtils()

        businessApi =  ioc?.container.resolve(IOCBusinessApiServiceProtocol.self)

        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        ResponseDataTest.errorCalled = 0

    }

    func testLinkedAccount() {
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "regToken": "123"]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 200009, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success(let data):
                XCTAssertEqual(data.callId, dic["callId"] as! String)
            case .failure:
                XCTFail()
            }
        })

    }

    func testLinkAccountError() {
        let dic: [String: Any] = ["errorCode": 5, "callId": "34324", "statusCode": 200, "regToken": "123"]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 403043, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        ResponseDataTest.errorCalled = -2

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTAssert(true)
            }
        })

    }

    func testResolverNotSupprted() {
        let dic: [String: Any] = ["errorCode": 20601, "callId": "34324", "statusCode": 200, "regToken": "123"]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 20601, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard let interruption = error.interruption else {
                    XCTAssert(true) // interruption not support
                    return }
            }
            XCTFail()
        })

    }
    
    func testLinkAccountResolver() {
        let dic: [String: Any] = ["errorCode": 403043, "callId": "34324", "statusCode": 200, "regToken": "123","conflictingAccount": ["loginProviders": ["googleplus"]]]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 403043, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        ResponseDataTest.errorCalled = 1

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTAssert(true)
            case .failure(let error):
                guard let interruption = error.interruption else { return }

                switch interruption {
                case .conflitingAccounts(let resolver):
                    resolver.linkToSite(loginId: "123", password: "123")
                default:
                    XCTFail()
                }
            }
        })

    }

    func testLinkAccountWithProviderResolver() {
        let dic: [String: Any] = ["errorCode": 403043, "callId": "34324", "statusCode": 200, "regToken": "123","conflictingAccount": ["loginProviders": ["googleplus"]]]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 403043, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        ResponseDataTest.errorCalled = 1

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTAssert(true)
            case .failure(let error):
                guard let interruption = error.interruption else { return }

                switch interruption {
                case .conflitingAccounts(let resolver):
                    let viewController = UIViewController()

                    ResponseDataTest.clientID = "123"
                    ResponseDataTest.providerToken = "123"

                    resolver.linkToSocial(provider: .google, viewController: viewController)
                default:
                    XCTFail()
                }
            }
        })

    }
}

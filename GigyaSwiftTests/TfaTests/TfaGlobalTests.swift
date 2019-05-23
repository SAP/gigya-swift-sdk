//
//  TfaGlobal.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 20/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class TfaGlobalTests: XCTestCase {
    var ioc: GigyaContainerUtils?

    var businessApi: IOCBusinessApiServiceProtocol?

    override func setUp() {
        ioc = GigyaContainerUtils()

        businessApi =  ioc?.container.resolve(IOCBusinessApiServiceProtocol.self)

        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        ResponseDataTest.errorCalled = 0

    }
    
    func testPendingRegistration() {
        let dic: [String: Any] = ["errorCode": 206002, "callId": "34324", "statusCode": 200, "regToken": "123"]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 206001, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard let interruption = error.interruption else { return }

                switch interruption {
                case .pendingRegistration(let regToken):
                    XCTAssertNotNil(regToken)
                default:
                    XCTFail()
                    break
                }
                break
            }
        })

    }

    func testPendingVirification() {
        let dic: [String: Any] = ["errorCode": 206002, "callId": "34324", "statusCode": 200, "regToken": "123"]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 206002, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard let interruption = error.interruption else { return }

                switch interruption {
                case .pendingVerification(let regToken):
                    XCTAssertNotNil(regToken)
                default:
                    XCTFail()
                    break
                }
                break
            }
        })

    }

    func testResolverNoneRegtoken() {
        let dic: [String: Any] = ["errorCode": 206002, "callId": "34324", "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 206002, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard let interruption = error.interruption else {
                    XCTAssert(true)
                    return
                }
            }

            XCTFail()
        })

    }
}


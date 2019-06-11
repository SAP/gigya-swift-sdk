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

    func testPendingPasswordChange() {
        let dic: [String: Any] = ["errorCode": 403100, "callId": "34324", "statusCode": 200, "regToken": "123"]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 403100, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard let interruption = error.interruption else { return }

                switch interruption {
                case .pendingPasswordChange(let regToken):
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
                guard let _ = error.interruption else {
                    XCTAssert(true)
                    return
                }
            }

            XCTFail()
        })

    }

    func testResolverRegistrationEmail() {
        let inactiveProviders = [["name": "gigyaPhone"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123", "inactiveProviders": inactiveProviders]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 403102, userInfo: ["callId": "dasdasdsad"])

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

                switch interruption {
                case .pendingTwoFactorRegistration(let resolver):
                    self.expectFatalError(expectedMessage: "[TFARegistrationResolver<RequestTestModel>]: email is not supported in registration ") {
                        resolver.verifyCode(provider: .email, authenticationCode: "123")
                    }
                default:
                    break
                }
            }

        })

    }


    // MARK: Multiintteruption
    func testLinkAccountResolverAndTotp() {
        let dic: [String: Any] = ["errorCode": 403043, "callId": "34324", "statusCode": 200, "regToken": "123","conflictingAccount": ["loginProviders": ["googleplus"]]]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 403043, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        ResponseDataTest.errorCalled = 1

        let email = "test@test.com"

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTAssert(true)
            case .failure(let error):
                guard let interruption = error.interruption else { return }

                switch interruption {
                case .conflitingAccounts(let resolver):
                    resolver.linkToSite(loginId: "123", password: "123")
                case .pendingTwoFactorVerification(let resolver):
                    resolver.startVerificationWithEmail()
                    resolver.sendEmailVerificationCode(registeredEmail: TFAEmail(id: email, obfuscated: "123", lastVerification: "123"))
                    resolver.verifyCode(provider: .email, authenticationCode: "1234")
                default:
                    XCTFail()
                }
            }
        })

    }
}


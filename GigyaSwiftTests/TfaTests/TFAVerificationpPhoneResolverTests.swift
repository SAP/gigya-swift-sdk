//
//  TFAVerificationResolverTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 21/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya
@testable import GigyaTfa

class TFAVerificationpPhoneResolverTests: XCTestCase {
    var ioc: GigyaContainerUtils?

    var businessApi: IOCBusinessApiServiceProtocol?

    override func setUp() {
        ioc = GigyaContainerUtils()

        businessApi =  ioc?.container.resolve(IOCBusinessApiServiceProtocol.self)

        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        ResponseDataTest.errorCalled = 0
        ResponseDataTest.errorCalledCallBack = {}

    }

    func runTfaVerificationPhoneResolver(with dic: [String: Any], callback: @escaping () -> () = {}, callback2: @escaping () -> () = {}, phone: String? = "123", errorCallback: @escaping (String) -> () = { error in XCTFail(error) }) {
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 403101, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success(let data):
                XCTAssertEqual(data.callId, dic["callId"] as! String)
            case .failure(let error):
                print(error) // general error
                if case .emptyResponse = error.error {
                    XCTAssert(true)
                    return
                }

                if case .jsonParsingError(let error) = error.error{
                    errorCallback(error.localizedDescription)
                }

                guard let interruption = error.interruption else {
                    if case .gigyaError(let eee) = error.error {
                        if eee.errorCode != 123 {
                            XCTFail()
                        }
                    }
                    return
                }
                // Evaluage interruption.
                switch interruption {
                case .pendingTwoFactorVerification(let interruption, let providers, let factory):
                    let resolver = factory.getResolver(for: RegisteredPhonesResolver.self)
                    // Reference inactive providers (registration).
                    callback()
                    resolver.getRegisteredPhones(completion: { (result) in
                        switch result {
                        case .registeredPhones(let phones):
                            callback2()
                            resolver.sendVerificationCode(with: phones.last!, method: .sms, completion: { (result) in
                                switch result {
                                case .verificationCodeSent(let resolver):
                                    resolver.verifyCode(provider: .phone, verificationCode: "123", rememberDevice: false, completion: { (result) in
                                        switch result {
                                        case .resolved:
                                            XCTAssertTrue(true)
                                        case .invalidCode:
                                            errorCallback("invalidCode")
                                        case .failed(let error):
                                            errorCallback(error.localizedDescription)
                                        }
                                    })
                                case .error(let error):
                                    errorCallback(error.localizedDescription)
                                default:
                                    break
                                }
                            })
                        case .verificationCodeSent(let resolver):
                            break
                        case .error(let error):
                            errorCallback(error.localizedDescription)
                        }
                    })
                default:
                    XCTFail()
                }
            }
        })
    }

    func testTfaSuccess() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "livelink"]]
        let phones = [["id": "4324", "obfuscated": "432432", "lastMethod": "d"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders, "phones": phones]

        runTfaVerificationPhoneResolver(with: dic, errorCallback: { error in
            XCTFail()
        })
    }

    func testTfaError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "error"]]
        let phones = [["id": "4324", "obfuscated": "432432", "lastMethod": "d"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders, "phones": phones]

        runTfaVerificationPhoneResolver(with: dic, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaiVerifyError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "livelink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaVerificationPhoneResolver(with: dic, callback2: {
            // swiftlint:disable force_try

            let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

            let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            // swiftlint:enable force_try

            ResponseDataTest.resData = jsonData
            ResponseDataTest.error = nil
        }, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaFinalizeError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "livelink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaVerificationPhoneResolver(with: dic, callback2: {
            ResponseDataTest.errorCalledCallBack = {
                if ResponseDataTest.errorCalled == 5 {
                    // swiftlint:disable force_try
                    ResponseDataTest.errorCalled = -2
                    let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

                    let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                    // swiftlint:enable force_try

                    ResponseDataTest.resData = jsonData
                    ResponseDataTest.error = nil

                }
            }
        }, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaSendSmsPhoneNotFoundError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "livelink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaVerificationPhoneResolver(with: dic, phone: nil, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaSendSmsError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "livelink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaVerificationPhoneResolver(with: dic, callback: {
            ResponseDataTest.errorCalledCallBack = {
                if ResponseDataTest.errorCalled == 3 {
                    // swiftlint:disable force_try
                    ResponseDataTest.errorCalled = -2
                    let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

                    let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                    // swiftlint:enable force_try

                    ResponseDataTest.resData = jsonData
                    ResponseDataTest.error = nil

                }
            }
        }, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaWithoutAssertion() {
        let activeProviders = [["name": "gigyaPhone"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200,"regToken": "123","activeProviders": activeProviders, "gigyaAssertion": ""]

        runTfaVerificationPhoneResolver(with: dic, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

}

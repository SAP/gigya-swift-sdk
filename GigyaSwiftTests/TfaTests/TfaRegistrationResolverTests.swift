//
//  TfaRegistrationResolver.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 21/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class TfaRegistrationPhoneResolverTests: XCTestCase {
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

    func runTfaRegistrationResolver(with dic: [String: Any], callback: @escaping () -> () = {}, callback2: @escaping () -> () = {}) {
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        let error = NSError(domain: "gigya", code: 403102, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success(let data):
                XCTAssertEqual(data.callId, dic["callId"] as! String)
            case .failure(let error):
                print(error) // general error
                if case .dataNotFound = error.error {
                    XCTAssert(true)
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
                case .pendingTwoFactorRegistration(let resolver):
                    // Reference inactive providers (registration).
                    callback()
                    resolver.startRegistrationWithPhone(phoneNumber: "123", method: "sms")
                    callback2()
                    resolver.verifyCode(provider: .gigyaPhone, authenticationCode: "1234")

                case .onPhoneVerificationCodeSent:
                    print("Phone verification code sent")
                case .onEmailVerificationCodeSent:
                    print("Email verification code send")
                case .onTotpQRCode(let code):
                    break
                default:
                    XCTFail()
                }
            }
        })
    }

    func testTfaSuccess() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "error"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaInitError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic, callback: {
            // swiftlint:disable force_try

            let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

            let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            // swiftlint:enable force_try

            ResponseDataTest.resData = jsonData

        })
    }

    func testTfaiVerifyError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic, callback2: {
            // swiftlint:disable force_try

            let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

            let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            // swiftlint:enable force_try

            ResponseDataTest.resData = jsonData
            ResponseDataTest.error = nil
        })
    }

    func testTfaFinalizeError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic, callback2: {
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
        })
    }

    func testTfaSendSmsError() {
        let activeProviders = [["name": "gigyaPhone"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic, callback: {
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
        })
    }

    func testTfaWithoutActiveProviders() {
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": []]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaWithoutAssertion() {
        let activeProviders = [["name": "gigyaPhone"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200,"regToken": "123","activeProviders": activeProviders]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaWithoutPhvToken() {
        let activeProviders = [["name": "gigyaPhone"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaWithoutProviderAssertion() {
        let activeProviders = [["name": "gigyaPhone"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","regToken": "123","activeProviders": activeProviders]

        runTfaRegistrationResolver(with: dic)
    }
}

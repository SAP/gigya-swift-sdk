//
//  TfaRegistrationTotpResolverTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 27/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class TfaRegistrationTotpResolverTests: XCTestCase {
    var ioc: GigyaContainerUtils?

    var businessApi: IOCBusinessApiServiceProtocol?

    let qrCodeImage = "data:image/png;base64,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"

    override func setUp() {
        ioc = GigyaContainerUtils()

        businessApi =  ioc?.container.resolve(IOCBusinessApiServiceProtocol.self)

        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        ResponseDataTest.errorCalled = 0
        ResponseDataTest.errorCalledCallBack = {}

    }

    func runTfaRegistrationResolver(with dic: [String: Any], callback: @escaping () -> () = {}, callback2: @escaping () -> () = {}, errorCallback: @escaping (String) -> () = { error in XCTFail(error) }) {
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
                case .pendingTwoFactorRegistration(let resolver):
                    // Reference inactive providers (registration).
                    callback()
                    resolver.startRegistrationWithTotp()
                    callback2()
                    resolver.verifyCode(provider: .totp, authenticationCode: "1234")

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
        let activeProviders = [["name": "gigyaTotp"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders, "sctToken": "123","qrCode": qrCodeImage]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaError() {
        let activeProviders = [["name": "gigyaTotp"]]
        let inactiveProviders = [["name": "error"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaInitError() {
        let activeProviders = [["name": "gigyaTotp"]]
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
        let activeProviders = [["name": "gigyaTotp"]]
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
        let activeProviders = [["name": "gigyaTotp"]]
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
        let activeProviders = [["name": "gigyaTotp"]]
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
        let activeProviders = [["name": "gigyaTotp"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200,"regToken": "123","activeProviders": activeProviders]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaWithoutPhvToken() {
        let activeProviders = [["name": "gigyaTotp"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaWithoutProviderAssertion() {
        let activeProviders = [["name": "gigyaTotp"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","regToken": "123","activeProviders": activeProviders]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaMakeQrFail() {
        let activeProviders = [["name": "gigyaTotp"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders, "sctToken": "123","qrCode": "gotof.ailed"]

        runTfaRegistrationResolver(with: dic)
    }
}

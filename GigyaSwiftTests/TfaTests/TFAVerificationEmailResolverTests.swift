//
//  TFAVerificationEmailResolverTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 23/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class TFAVerificationpEmailResolverTests: XCTestCase {
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

    func runTfaVerificationEmailResolver(with dic: [String: Any], callback: @escaping () -> () = {}, callback2: @escaping () -> () = {}, email: String? = "test@test.com", errorCallback: @escaping (String) -> () = { error in XCTFail(error) }) {
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
                if case .dataNotFound = error.error {
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
                case .pendingTwoFactorVerification(let resolver):
                    // Reference inactive providers (registration).
                    callback()
                    resolver.startVerificationWithEmail()
                    callback2()
                    resolver.sendEmailVerificationCode(registeredEmail: TFAEmail(id: email, obfuscated: "123", lastVerification: "123"))

                    resolver.verifyCode(provider: .email, authenticationCode: "1234")

                case .onPhoneVerificationCodeSent:
                    print("Phone verification code sent")
                case .onEmailVerificationCodeSent:
                    print("Email verification code send")
                case .onRegisteredEmails(let emails):
                    break
                case .onTotpQRCode(let code):
                    break
                default:
                    XCTFail()
                }
            }
        })
    }

    func testTfaSuccess() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "liveLink"]]
        let emails = [["id": "test@test.com", "obfuscated": "123", "lastVerification": "123"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders, "emails": emails]

        runTfaVerificationEmailResolver(with: dic)
    }

    func testTfaError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "error"]]
        let emails = [["id": "test@test.com", "obfuscated": "123", "lastVerification": "123"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders, "emails": emails]

        runTfaVerificationEmailResolver(with: dic, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaiVerifyError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaVerificationEmailResolver(with: dic, callback2: {
            // swiftlint:disable force_try

            let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

            let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            // swiftlint:enable force_try

            ResponseDataTest.resData = jsonData
            ResponseDataTest.error = nil
        })
    }

    func testTfaFinalizeError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaVerificationEmailResolver(with: dic, callback2: {
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

    func testTfaSendEmailCodeNotFoundError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaVerificationEmailResolver(with: dic, email: "")
    }

    func testTfaSendSmsError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "liveLink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        runTfaVerificationEmailResolver(with: dic, callback: {
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

    func testTfaWithoutAssertion() {
        let activeProviders = [["name": "gigyaEmail"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200,"regToken": "123","activeProviders": activeProviders]

        runTfaVerificationEmailResolver(with: dic)
    }

    func testTfaWithoutGigyaAssertionAfterInit() {
        let activeProviders = [["name": "gigyaEmail"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200,"gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders]

        runTfaVerificationEmailResolver(with: dic, callback: {
            ResponseDataTest.errorCalledCallBack = {
                print(ResponseDataTest.errorCalled)
                if ResponseDataTest.errorCalled == 3 {
                    let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

                    let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                    // swiftlint:enable force_try

                    ResponseDataTest.resData = jsonData
                    ResponseDataTest.error = nil
                }
            }

        })
    }

}


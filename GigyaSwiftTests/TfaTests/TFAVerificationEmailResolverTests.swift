//
//  TFAVerificationEmailResolverTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 23/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya
@testable import GigyaTfa

class TFAVerificationpEmailResolverTests: XCTestCase {
    var ioc = GigyaContainerUtils.shared

    var businessApi: BusinessApiServiceProtocol?

    var resolver: RegisteredEmailsResolver<RequestTestModel>?

    override func setUp() {
        ioc = GigyaContainerUtils()

        businessApi =  ioc.container.resolve(BusinessApiServiceProtocol.self)

        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        ResponseDataTest.errorCalled = 0
        ResponseDataTest.errorCalledCallBack = {}

    }

    func runTfaVerificationEmailResolver(with dic: [String: Any], callback: @escaping () -> () = {}, callback2: @escaping () -> () = {}, email: String? = "test@test.com", errorCallback: @escaping (String) -> () = { _ in }) {
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
                    self.resolver = factory.getResolver(for: RegisteredEmailsResolver.self)
                    // Reference inactive providers (registration).
                    callback()
                    self.resolver?.getRegisteredEmails(completion: { (result) in
                        switch result {
                        case .registeredEmails(let emails):
                            self.resolver?.sendEmailCode(with: emails.last!, completion: { (result) in
                                switch result {
                                case .emailVerificationCodeSent(let resolver):
                                    callback2()
                                    resolver.verifyCode(provider: .email, verificationCode: "123", rememberDevice: false, completion: { (result) in
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
                        case .error(let error):
                            errorCallback(error.localizedDescription)
                        default:
                            break

                        }
                    })
                default:
                    XCTFail()
                }
            }
        })

    }

    func testTfaSuccess() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "livelink"]]
        let emails = [["id": "test@test.com", "obfuscated": "123", "lastVerification": "123"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders, "emails": emails]

        runTfaVerificationEmailResolver(with: dic)
    }

    func testTfaError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "error"]]
        let emails = [["id": "test@test.com", "obfuscated": "123", "lastVerification": "123"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders, "emails": emails]

        let expectation = self.expectation(description: "emailTestTfaError")

        runTfaVerificationEmailResolver(with: dic, errorCallback: { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: 5, handler: nil)

    }

    func testTfaiVerifyError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "livelink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        let expectation = self.expectation(description: "emailTestTfaiVerifyError")

        runTfaVerificationEmailResolver(with: dic, callback2: {
            // swiftlint:disable force_try

            let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

            let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            // swiftlint:enable force_try

            ResponseDataTest.resData = jsonData
            ResponseDataTest.error = nil
        }, errorCallback: { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        })

        self.waitForExpectations(timeout: 5, handler: nil)

    }

    func testTfaFinalizeError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "livelink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        let expectation = self.expectation(description: "emailTestTfaFinalizeError")

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
        }, errorCallback: { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        })

        self.waitForExpectations(timeout: 5, handler: nil)

    }

    func testTfaSendEmailCodeNotFoundError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "livelink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        let expectation = self.expectation(description: "emailTestTfaSendEmailCodeNotFoundError")

        runTfaVerificationEmailResolver(with: dic, email: "", errorCallback: { error in
            XCTAssertNotNil(error)
            expectation.fulfill()

        })
        self.waitForExpectations(timeout: 5, handler: nil)

    }

    func testTfaSendSmsError() {
        let activeProviders = [["name": "gigyaEmail"]]
        let inactiveProviders = [["name": "livelink"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders, "inactiveProviders": inactiveProviders]

        let expectation = self.expectation(description: "emailTestTfaSendSmsError")

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
        }, errorCallback: { error in
            XCTAssertNotNil(error)
            expectation.fulfill()

        })
        self.waitForExpectations(timeout: 5, handler: nil)

    }

    func testTfaWithoutAssertion() {
        let activeProviders = [["name": "gigyaEmail"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200,"regToken": "123","activeProviders": activeProviders]


        runTfaVerificationEmailResolver(with: dic, errorCallback: { error in
            XCTAssertNotNil(error)
        })

    }

    func testTfaWithoutGigyaAssertionAfterInit() {
        let activeProviders = [["name": "gigyaEmail"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200,"gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": activeProviders]
        let expectation = self.expectation(description: "emailTestTfaWithoutGigyaAssertionAfterInit")

        runTfaVerificationEmailResolver(with: dic, callback: {
            ResponseDataTest.errorCalledCallBack = {
                print(ResponseDataTest.errorCalled)
                if ResponseDataTest.errorCalled == 3 {
                    let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

                    let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                    // swiftlint:enable force_try

                    ResponseDataTest.resData = jsonData
                    ResponseDataTest.error = nil
                    ResponseDataTest.errorCalledCallBack = { }
                }
            }

        }, errorCallback: { error in
            expectation.fulfill()

            XCTAssertNotNil(error)

        })
        self.waitForExpectations(timeout: 5, handler: nil)

    }

}


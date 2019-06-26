//
//  TfaRegistrationResolver.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 21/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya
@testable import GigyaTfa

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
                if case .emptyResponse = error.error {
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
                case .pendingTwoFactorRegistration(let interruption, let providers, let factory):
                    // Reference inactive providers (registration).
                    let resolver = factory.getResolver(for: RegisterPhoneResolver.self)
                    let _ = providers

                    callback()
                    resolver.registerPhone(phone: "123", completion: { result in
                        switch result {
                        case .verificationCodeSent(let verifyResolver):
                            callback2()
                            verifyResolver.verifyCode(provider: .phone, verificationCode: "123", rememberDevice: false, completion: { (res) in
                                switch res {
                                case .resolved:
                                    XCTAssertTrue(true)
                                case .invalidCode:
                                    errorCallback("invalidCode")
                                case .failed(_):
                                    errorCallback("Error")
                                }
                            })
                        case .error(let error):
                            errorCallback(error.localizedDescription)
                        }
                    })

                default:
                    errorCallback("Error")
                }
            }
        })
    }

    func testTfaSuccess() {
        let inactiveProviders = [["name": "gigyaPhone"]]
     
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123", "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaError() {
        let inactiveProviders = [["name": "error"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123", "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaInitError() {
        let inactiveProviders = [["name": "gigyaPhone"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123", "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic, callback: {
            // swiftlint:disable force_try

            let dic: [String: Any] = ["errorCode": 123, "callId": "34324", "statusCode": 200]

            let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            // swiftlint:enable force_try

            ResponseDataTest.resData = jsonData

        }, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaiVerifyError() {
        let inactiveProviders = [["name": "gigyaPhone"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123", "inactiveProviders": inactiveProviders]

        runTfaRegistrationResolver(with: dic, callback2: {
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
        let inactiveProviders = [["name": "gigyaPhone"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123", "inactiveProviders": inactiveProviders]

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
        }, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaSendSmsError() {

        let inactiveProviders = [["name": "gigyaPhone"]]

        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123", "inactiveProviders": inactiveProviders]

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
        }, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }

    func testTfaWithoutActiveProviders() {
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","providerAssertion": "123","regToken": "123","activeProviders": []]

        runTfaRegistrationResolver(with: dic)
    }

    func testTfaWithoutAssertionAndPhv() {
        let activeProviders = [["name": "gigyaPhone"]]
        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200,"regToken": "123","activeProviders": activeProviders]

        runTfaRegistrationResolver(with: dic, errorCallback: { error in
            XCTAssertNotNil(error)
        })
    }
//
//    func testTfaWithoutProviderAssertion() {
//        let activeProviders = [["name": "gigyaPhone"]]
//        let dic: [String: Any] = ["errorCode": 0, "callId": "34324", "statusCode": 200, "gigyaAssertion": "123","phvToken": "123","regToken": "123","activeProviders": activeProviders]
//
//        runTfaRegistrationResolver(with: dic)
//    }
}

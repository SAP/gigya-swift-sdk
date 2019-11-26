//
//  PushAuthenticationTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 21/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya
@testable import GigyaAuth

class PushLoginTests: XCTestCase {
    let ioc = GigyaContainerUtils.shared

    var pushManager: PushLoginManager?
    var pushService: PushNotificationsServiceProtocol?

    override func setUp() {
        ioc.container.register(service: BiometricServiceProtocol.self, isSingleton: true) { (resolver) in
            return BiometricServiceMock()
        }

        pushService = ioc.container.resolve(PushNotificationsServiceProtocol.self)

        ioc.container.register(service: PushNotificationsServiceProtocol.self) { (resolver) in
            return self.pushService!
        }
        
        pushManager = PushLoginManager(container: ioc.container)
    }

    override func tearDown() {
        let pushServiceMock = pushService as! PushNotificationsServiceMock
        pushServiceMock.pushTokenMock = "test"
        pushServiceMock.registerPushResultMock = true

        let biometric = ioc.container.resolve(BiometricServiceProtocol.self) as! BiometricServiceMock

        biometric.setOptIn()

        ioc.registerDependencie(UserDataModel.self)
    }

    func testRegisterToPushAuthSuccess() {
        let pushServiceMock = pushService as! PushNotificationsServiceMock
        pushServiceMock.pushTokenMock = "123"
        pushServiceMock.registerPushResultMock = true

        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        ResponseDataTest.resData = jsonData

        pushManager?.beforeRegisterDeviceToPushLogin(completion: { (result) in
            switch result {
            case .success(let data):
                XCTAssertEqual(data["callId"]?.value as! String, "34324")
            case .failure(_):
                XCTFail()
            }
        })
    }

    func testRegisterToPushAuthFailed() {
        let dic: [String: Any] = ["callId": "34324", "errorCode": 50, "statusCode": 200]

        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        ResponseDataTest.resData = jsonData

        let pushServiceMock = pushService as! PushNotificationsServiceMock
        pushServiceMock.registerPushResultMock = true

        pushManager?.beforeRegisterDeviceToPushLogin(completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual("The operation couldn’t be completed. (Gigya.NetworkError error 1.)", error.localizedDescription)
            }
        })
    }

    func testRegisterToPushAuthPermissionDenied() {
        let pushServiceMock = pushService as! PushNotificationsServiceMock
        pushServiceMock.pushTokenMock = nil
        pushServiceMock.registerPushResultMock = false

        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        ResponseDataTest.resData = jsonData

        pushManager?.beforeRegisterDeviceToPushLogin(completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                switch error {
                case .providerError(let data):
                    XCTAssertEqual("Permission denied - push notificiations not allowed", data)
                default:
                    XCTFail()
                }
            }
        })
    }

    func testRegisterToPushAuthPushTokenNotExists() {
        let pushServiceMock = pushService as! PushNotificationsServiceMock
        pushServiceMock.pushTokenMock = nil
        pushServiceMock.registerPushResultMock = true
        
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        ResponseDataTest.resData = jsonData

        pushManager?.beforeRegisterDeviceToPushLogin(completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                switch error {
                case .providerError(let data):
                    XCTAssertEqual("push token not exists", data)
                default:
                    XCTFail()
                }
            }
        })
    }

    func testVerifyPush() {
        // push verfication result
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        ResponseDataTest.resData = jsonData


        let notification: [AnyHashable: Any] = ["type": "AuthChallenge", "mode": "verify", "vToken": "123", "title": "test", "body": "test"]

        pushService?.verifyPush(response: notification)

        let generalUtils = ioc.container.resolve(GeneralUtils.self) as! GeneralUtilsMock

        generalUtils.showNotificationTextTestClosure = { body in
            XCTAssertEqual(body, "Successfully authenticated login request")
        }

    }

    // MARK: Test with biometric enabled

    func testRegisterToPushAuthBiometricSuccess() {
        let pushServiceMock = pushService as! PushNotificationsServiceMock
        pushServiceMock.pushTokenMock = "test"
        pushServiceMock.registerPushResultMock = true

        let biometric = ioc.container.resolve(BiometricServiceProtocol.self) as! BiometricServiceMock
        biometric.setOptIn()
        
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        ResponseDataTest.resData = jsonData

        let notification: [AnyHashable: Any] = ["type": "AuthChallenge", "mode": "verify", "vToken": "123", "title": "test", "body": "test"]

        pushService?.verifyPush(response: notification)

        let generalUtils = ioc.container.resolve(GeneralUtils.self) as! GeneralUtilsMock

        generalUtils.showNotificationTextTestClosure = { body in
            XCTAssertEqual(body, "Successfully authenticated login request")
        }
    }
}

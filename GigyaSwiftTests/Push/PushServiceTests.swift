//
//  PushServiceTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 25/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class PushServiceTests: XCTestCase {
    let ioc = GigyaContainerUtils.shared
    typealias PushProtocol = PushNotificationsServiceProtocol & PushNotificationsServiceExternalProtocol

    var pushService: PushProtocol?

    var persistenceService: PersistenceService?

    override func setUp() {

        ioc.container.register(service: SessionServiceProtocol.self) { (resolver) in
            return SessionServiceMock()
        }

        pushService = ioc.container.resolve(PushNotificationsServiceProtocol.self) as? PushProtocol

        persistenceService = ioc.container.resolve(PersistenceService.self)

        persistenceService?.setPushKey(to: "")

    }


    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        ioc.registerDependencie(UserDataModel.self)
    }

    func testUpdatePushKey() {
        
        let newKey = "123"
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        ResponseDataTest.resData = jsonData

        pushService?.savePushKey(key: newKey)

        let expectation = self.expectation(description: "checkUpdatePush")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(persistenceService?.pushKey, newKey)

        XCTAssertEqual(pushService?.getPushToken(), newKey)

    }

    func testForegroundPush() {
        let notification: [AnyHashable: Any] = ["type": "AuthChallenge", "mode": "verify", "vToken": "123", "title": "test", "body": "testForegroundPush"]


        let generalUtils = ioc.container.resolve(GeneralUtils.self) as! GeneralUtilsMock

        generalUtils.showNotificationTextTestClosure = { body in
            XCTAssertEqual(body, "testForegroundPush")
        }

        pushService?.foregrundNotification(with: notification)

    }

    func testRemovePush() {
        let notification: [AnyHashable: Any] = ["type": "AuthChallenge", "mode": "cancel", "vToken": "123", "title": "test", "body": "testForegroundPush"]

        let userNotifications = ioc.container.resolve(UserNotificationCenterProtocol.self) as! UserNotificationCenterMock
        userNotifications.notification = ["123": notification]

        userNotifications.deleteNotificationTextTestClosure = { id in
            XCTAssertEqual(id, "123")
        }

        pushService?.onRecivePush(userInfo: notification, completion: { _ in

        })

    }

    func testRemoveMultiPush() {
        let notification: [AnyHashable: Any] = ["type": "AuthChallenge", "mode": "cancel", "vToken": "123", "title": "test", "body": "testForegroundPush"]

        let notifications = ["1": notification, "2": notification, "3": notification]

        let userNotifications = ioc.container.resolve(UserNotificationCenterProtocol.self) as! UserNotificationCenterMock
        userNotifications.notification = notifications

        userNotifications.deleteNotificationTextTestClosure = { id in
            XCTAssertNotNil(notifications[id])
        }

        pushService?.onRecivePush(userInfo: notification, completion: { _ in

        })


    }
}


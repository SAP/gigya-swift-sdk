//
//  UserNotificationCenterMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 25/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import XCTest
@testable import Gigya

class UserNotificationCenterMock: UserNotificationCenterProtocol {

    var notification: [String: [AnyHashable : Any]] = [:]

    var deleteNotificationTextTestClosure: (String) -> () = { _ in XCTFail() }

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(true, nil)
    }

    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {

    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        for id in identifiers {
            deleteNotificationTextTestClosure(id)
        }
    }

    func getDeliveredNotifications(completionHandler: @escaping ([String : [AnyHashable : Any]]) -> Void) {
        completionHandler(notification)
    }
}

//
//  UserNotificationCenterHelper.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 25/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications

class UserNotificationCenterHelper: UserNotificationCenterProtocol {
    let current = UNUserNotificationCenter.current()

    func requestAuthorization(options: UNAuthorizationOptions = [], completionHandler: @escaping (Bool, Error?) -> Void) {
        current.requestAuthorization(options: options, completionHandler: completionHandler)
    }

    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        current.getNotificationSettings(completionHandler: completionHandler)
    }

    func getDeliveredNotifications(completionHandler: @escaping ([String: [AnyHashable: Any]]) -> Void) {
        current.getDeliveredNotifications { (deliveredNotifications) in
            var notifications: [String: [AnyHashable: Any]] = [:]

            for notification in deliveredNotifications {
                notifications[notification.request.identifier] = notification.request.content.userInfo
            }
            
            completionHandler(notifications)
        }
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        current.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}

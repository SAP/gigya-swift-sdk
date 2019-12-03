//
//  UserNotificationCenterProtocol.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 02/12/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications

protocol UserNotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)

    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)

    func removeDeliveredNotifications(withIdentifiers identifiers: [String])

    func getDeliveredNotifications(completionHandler: @escaping ([String: [AnyHashable: Any]]) -> Void)
}

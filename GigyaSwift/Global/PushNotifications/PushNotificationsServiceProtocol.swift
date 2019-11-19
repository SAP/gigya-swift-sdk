//
//  PushNotificationsServiceProtocol.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 18/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import UserNotifications

public typealias InstanceRegistred = (UNNotificationResponse) -> ()

protocol PushNotificationsServiceProtocol {

    func savePushKey(key: String)

    func foregrundNotification(with data: [AnyHashable : Any])
    
    func onRecivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void)

    func verifyPush(response: UNNotificationResponse)
}

public protocol PushNotificationsServiceExternalProtocol {
    func getPushToken() -> String?
    
    func registerTo(_ clousre: @escaping InstanceRegistred)

    func registerForPushNotifications(compilation: @escaping (_ success: Bool) -> ())
}

//
//  PushNotificationsServiceProtocol.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 18/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import UserNotifications

public typealias RemoteMsgClosure = ([AnyHashable : Any]) -> ()

protocol PushNotificationsServiceProtocol {

    func savePushKey(key: String)

    func foregroundNotification(with data: [AnyHashable : Any])
    
    func onReceivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void)

    func verifyPush(response: [AnyHashable : Any])
}

public protocol PushNotificationsServiceExternalProtocol {
    func getPushToken() -> String?
    
    func registerTo(key: String, closure: @escaping RemoteMsgClosure)

    func registerForPushNotifications(compilation: @escaping (_ success: Bool) -> ())

    func getNotificationSettings(_ compilation: @escaping (_ success: Bool) -> ())
}

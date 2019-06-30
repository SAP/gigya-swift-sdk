//
//  IOCPushNotificationsService.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 16/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya

protocol PushNotificationsServiceProtocol {

    func onRecivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void)

    func savePushKey(key: String)

    func verifyPushTfa(response: UNNotificationResponse)
    
    func optInToPushTfa(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)
}

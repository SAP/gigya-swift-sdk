//
//  IOCPushNotificationsService.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 16/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya

protocol PushTfaManagerProtocol {

    func verifyPushTfa(response: UNNotificationResponse)
    
    func optInToPushTfa(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)
}

//
//  IOCPushNotificationsService.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 16/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSwift

protocol IOCPushNotificationsService {

    func onRecivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void)

//    func registerForPushNotifications(compilation: @escaping (_ success: Bool) -> ())

    func savePushKey(key: String)

    func optInToPushTfa()
}

//
//  GigyaAuth.swift
//  GigyaAuth
//
//  Created by Shmuel, Sagi on 20/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

final public class GigyaAuth {

    public static let shared: GigyaAuth = GigyaAuth()

    private let pushLoginManager: PushLoginManager

    init() {
        self.pushLoginManager = PushLoginManager(container: Gigya.getContainer())
    }

    /**
     Check if the user is authorized to remote notifications
     */
    
    public func registerForRemoteNotifications() {
        pushLoginManager.pushService.getNotificationSettings { _ in }
    }

    /**
     Request to register device to push authentication.

      - Parameter completion: Request response.
      */
    public func registerForAuthPush(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        pushLoginManager.beforeRegisterDeviceToPushLogin(completion: completion)
    }
}

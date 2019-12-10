//
//  GigyaTfa.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 17/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya

final public class GigyaTfa {

    public static let shared: GigyaTfa = GigyaTfa()

    private let pushTfaManager: PushTfaManager

    init() {
        self.pushTfaManager = PushTfaManager()
    }

    // MARK: Push TFA - Available in iOS 10+

    /**
     Check if the user is authorized to remote notifications
     */
    public func registerForRemoteNotifications() {
        pushTfaManager.pushService.getNotificationSettings { _ in }
    }
    
    /**
     Request to Opt-In to push Two Factor Authentication.
     This is the first of two stages of the Opt-In process.

      - Parameter completion: Request response.
      */

    public func OptiInPushTfa(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        pushTfaManager.optInToPushTfa(completion: completion)
    }

}

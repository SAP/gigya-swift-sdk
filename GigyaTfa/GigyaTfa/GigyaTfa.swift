//
//  GigyaTfa.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 17/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya

public class GigyaTfa {

    public static let shared: GigyaTfa = GigyaTfa()

    private let pushManager: PushTfaManager

    init() {
        self.pushManager = PushTfaManager()
    }

    // MARK: Push TFA - Available in iOS 10+

    /**
     Request to Opt-In to push Two Factor Authentication.
     This is the first of two stages of the Opt-In process.

      - Parameter completion: Request response.
      */

    public func OptiInPushTfa(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        pushManager.optInToPushTfa(completion: completion)
    }

}

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

    public func registerDeviceToPushLogin(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        pushLoginManager.beforeRegisterDeviceToPushLogin(completion: completion)
    }
}

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

    private var dependenciesContainer = Gigya.getContainer()

    public static let shared: GigyaAuth = GigyaAuth()

    private let pushLoginManager: PushLoginManager

    public lazy var otp: OtpServiceProtocol = {
        return dependenciesContainer.resolve(OtpServiceProtocol.self)!
    }()

    init() {
        self.pushLoginManager = PushLoginManager(container: dependenciesContainer)
    }

    public func register<T: GigyaAccountProtocol>(scheme: T.Type) {
        dependenciesContainer.register(service: OtpServiceProtocol.self) { resolver in
            let businessApi = resolver.resolve(BusinessApiDelegate.self)!

            return OtpService<T>(businessApi: businessApi)
        }

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

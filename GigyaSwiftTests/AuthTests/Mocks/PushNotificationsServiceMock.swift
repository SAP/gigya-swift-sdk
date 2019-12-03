//
//  PushNotificationsServiceMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 21/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

@testable import Gigya

class PushNotificationsServiceMock: PushNotificationsService {
    var pushTokenMock: String?

    var registerPushResultMock: Bool = true

    let ioc = GigyaContainerUtils.shared

    override init(apiService: ApiServiceProtocol, sessionService: SessionServiceProtocol, biometricService: BiometricServiceProtocol, generalUtils: GeneralUtils, persistenceService: PersistenceService, userNotificationCenter: UserNotificationCenterProtocol) {
        let biometric = ioc.container.resolve(BiometricServiceMock.self)!
        
        super.init(apiService: apiService, sessionService: sessionService, biometricService: biometric, generalUtils: generalUtils, persistenceService: persistenceService, userNotificationCenter: userNotificationCenter)
    }
    
    override func getPushToken() -> String? {
        return pushTokenMock ?? super.getPushToken()
    }

    override func registerForPushNotifications(compilation: @escaping (Bool) -> ()) {
        if registerPushResultMock {
            compilation(registerPushResultMock)
        } else {
//            compilation(registerPushResultMock)
            super.registerForPushNotifications(compilation: compilation)
        }
    }


}

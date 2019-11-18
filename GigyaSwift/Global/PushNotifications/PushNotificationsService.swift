//
//  PushNotificationsService.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 18/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//
import UIKit
import UserNotifications

class PushNotificationsService: PushNotificationsServiceProtocol {

    let apiService: ApiServiceProtocol

    let sessionService: SessionServiceProtocol

    let biometricService: BiometricServiceProtocol

    // User defaults params
    let pushSaveKey = "com.gigya.GigyaTfa:pushKey"

    init(apiService: ApiServiceProtocol, sessionService: SessionServiceProtocol, biometricService: BiometricServiceProtocol) {
        self.apiService = apiService
        self.sessionService = sessionService
        self.biometricService = biometricService
    }

    private var pushToken: String? {
        didSet {
            sendPushKeyIfNeeded()
        }
    }

    // MARK: Register for push notification
    func registerForPushNotifications(compilation: @escaping (_ success: Bool) -> ()) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                guard let self = self else { return }

                GigyaLogger.log(with: self, message: "Permission granted: \(granted)")
                guard granted else {
                    GigyaLogger.log(with: self, message: "Permission denied: error(\(error?.localizedDescription ?? ""))")

                    compilation(false)
                    return
                }
                self.getNotificationSettings(compilation)
        }
    }

    private func getNotificationSettings(_ compilation: @escaping (_ success: Bool) -> ()) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            GigyaLogger.log(with: self, message: "Notification settings: \(settings)")

            guard settings.authorizationStatus == .authorized else {
                GigyaLogger.log(with: self, message: "Permission denied")

                compilation(false)
                return
            }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }

            compilation(true)
        }
    }

    // MARK: Delete push's

    func onRecivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { deliveredNotifications -> () in

            GigyaLogger.log(with: self, message: "\(deliveredNotifications.count) Delivered notifications-------")

            let modeString = userInfo["mode"] as? String ?? ""
            let mode = PushNotificationModes(rawValue: modeString) ?? .verify

            // delete push notification with cancel mode
            if mode == .cancel {
            // remove push by gigyaAssertion
                for notification in deliveredNotifications {
                    if let gid = notification.request.content.userInfo["gigyaAssertion"] as? String,
                        let idToDelete = userInfo["gigyaAssertion"] as? String,
                        gid.contains(idToDelete)
                    {
                        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                    }


                    print(notification.request.identifier)
                }
            }

            completion(.newData)

        })
    }

    // MARK: Push key management

    func savePushKey(key: String) {
        pushToken = key
    }

    private func sendPushKeyIfNeeded() {
        let key = UserDefaults.standard.object(forKey: pushSaveKey) as? String ?? ""

        guard let pushToken = pushToken, sessionService.isValidSession() == true else { return } // TODO: add session validation

        guard !pushToken.contains(key) else {
            return
        }

        let model = ApiRequestModel(method: GigyaDefinitions.API.pushUpdateDeviceTFA, params: ["platform": "ios", "os": GeneralUtils.iosVersion(), "man": "apple", "pushToken": pushToken])

        apiService.send(model: model, responseType: GigyaDictionary.self) { result in
            switch result {
            case .success:
                UserDefaults.standard.set(pushToken, forKey: self.pushSaveKey)
            case .failure(let error):
                GigyaLogger.log(with: self, message: error.localizedDescription)
            }
        }

    }

    // MARK: Verification push

    func verifyPush(response: UNNotificationResponse) {

    }
}

//
//  PushNotificationsService.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 18/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//
import UIKit
import UserNotifications

class PushNotificationsService: PushNotificationsServiceExternalProtocol, PushNotificationsServiceProtocol {

    let apiService: ApiServiceProtocol

    let sessionService: SessionServiceProtocol

    let biometricService: BiometricServiceProtocol

    let persistenceService: PersistenceService

    let generalUtils: GeneralUtils

    var registredClosures: [InstanceRegistred] = []

    init(apiService: ApiServiceProtocol, sessionService: SessionServiceProtocol, biometricService: BiometricServiceProtocol, generalUtils: GeneralUtils, persistenceService: PersistenceService) {
        self.apiService = apiService
        self.sessionService = sessionService
        self.biometricService = biometricService
        self.generalUtils = generalUtils
        self.persistenceService = persistenceService
    }

    private var pushToken: String? {
        didSet {
            sendPushKeyIfNeeded()
        }
    }

    func getPushToken() -> String? {
        return pushToken
    }

    // MARK:  Register Closure for verification push
    func registerTo(_ closure: @escaping InstanceRegistred) {
        registredClosures.append(closure)
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

    // MARK: Show foregrund notification

    func foregrundNotification(with data: [AnyHashable : Any]) {
        let title = data["title"] as? String ?? ""
        let body = data["body"] as? String ?? ""
        let gigyaAssertion = data["gigyaAssertion"] as? String ?? ""

        generalUtils.showNotification(title: title, body: body, id: gigyaAssertion, userInfo: data)
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
        let key = persistenceService.pushKey ?? ""

        guard let pushToken = pushToken, sessionService.isValidSession() == true else { return } // TODO: add session validation

        guard !pushToken.contains(key) else {
            return
        }

        let model = ApiRequestModel(method: GigyaDefinitions.API.pushUpdateDeviceTFA, params: ["platform": "ios", "os": generalUtils.iosVersion(), "man": "apple", "pushToken": pushToken])

        apiService.send(model: model, responseType: GigyaDictionary.self) { [weak persistenceService] result in
            switch result {
            case .success:
                persistenceService?.setPushKey(to: pushToken)
            case .failure(let error):
                GigyaLogger.log(with: self, message: error.localizedDescription)
            }
        }
    }

    // MARK: Verification push

    func verifyPush(response: UNNotificationResponse) {
        registredClosures.forEach { (closure) in
            closure(response)
        }
    }
}

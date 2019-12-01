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

    let userNotificationCenter: UserNotificationCenterProtocol

    private var instanceKeysRegistry: [String] = []

    private var closureRegistry: [RemoteMsgClosure] = []

    init(apiService: ApiServiceProtocol, sessionService: SessionServiceProtocol, biometricService: BiometricServiceProtocol, generalUtils: GeneralUtils, persistenceService: PersistenceService, userNotificationCenter: UserNotificationCenterProtocol) {
        self.apiService = apiService
        self.sessionService = sessionService
        self.biometricService = biometricService
        self.generalUtils = generalUtils
        self.persistenceService = persistenceService
        self.userNotificationCenter = userNotificationCenter
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

    func registerTo(key: String, closure: @escaping RemoteMsgClosure) {
        closureRegistry.append(closure)
        instanceKeysRegistry.append(key)
    }

    // MARK: Register for push notification

    func registerForPushNotifications(compilation: @escaping (_ success: Bool) -> ()) {
        userNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
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

    func getNotificationSettings(_ compilation: @escaping (_ success: Bool) -> ()) {
        userNotificationCenter.getNotificationSettings { settings in
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
        guard sessionService.isValidSession() == true else {
            return
        }

        let title = data["title"] as? String ?? ""
        let body = data["body"] as? String ?? ""
        var id = ""

        for remoteId in instanceKeysRegistry {
            if let getId = data[remoteId] as? String {
                id = getId
            }
        }

        generalUtils.showNotification(title: title, body: body, id: id, userInfo: data)
    }

    // MARK: Delete push's

    func onRecivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        userNotificationCenter.getDeliveredNotifications(completionHandler: { [weak self] deliveredNotifications -> () in
            guard let self = self else { return }

            GigyaLogger.log(with: self, message: "\(deliveredNotifications.count) Delivered notifications-------")

            let modeString = userInfo["mode"] as? String ?? ""
            let mode = PushNotificationModes(rawValue: modeString) ?? .verify

            // delete push notification with cancel mode
            if mode == .cancel {
            // remove push by id
                for (identifier, notification) in deliveredNotifications {
                    if self.needToDeleted(userInfoFrom: notification, userInfoFromPush: userInfo)
                    {
                        self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
                    }
                }
            }

            // remove the all nofitication when the session is not valid
            if self.sessionService.isValidSession() == false {
                for (identifier, notification) in deliveredNotifications {
                    if self.needToDeleted(userInfoFrom: notification, userInfoFromPush: notification)
                    {
                        self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
                    }
                }
            }

            completion(.newData)

        })
    }

    private func needToDeleted(userInfoFrom: [AnyHashable : Any], userInfoFromPush: [AnyHashable : Any]) -> Bool{
        for remoteId in instanceKeysRegistry {
            if let gid = userInfoFrom[remoteId] as? String,
                let idToDelete = userInfoFromPush[remoteId] as? String,
                gid.contains(idToDelete)
            {
                return true
            }
        }

        return false
    }

    // MARK: Push key management

    func savePushKey(key: String) {
        pushToken = key
    }

    private func sendPushKeyIfNeeded() {
        let key = persistenceService.pushKey ?? ""

        guard let pushToken = pushToken, sessionService.isValidSession() == true, !pushToken.contains(key) else {
            return
        }

        let model = ApiRequestModel(method: GigyaDefinitions.API.pushUpdateDevice, params: ["platform": "ios", "os": generalUtils.iosVersion(), "man": "apple", "pushToken": pushToken])

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

    func verifyPush(response: [AnyHashable : Any]) {
        closureRegistry.forEach { (closure) in
            closure(response)
        }
    }
}

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

    private var handlersRegistry: [String: RemoteMsgClosure] = [:]

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
        handlersRegistry[key] = closure
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

    func foregroundNotification(with data: [AnyHashable : Any]) {
        guard sessionService.isValidSession() == true else {
            return
        }

        let title = data["title"] as? String
        let body = data["body"] as? String
        var id: String?

        for remoteId in handlersRegistry.keys {
            if let getId = data[remoteId] as? String {
                id = getId
            }
        }

        if let title = title, let body = body, let id = id {
            generalUtils.showNotification(title: title, body: body, id: id, userInfo: data)
        }
    }

    // MARK: Delete push's

    func onReceivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        userNotificationCenter.getDeliveredNotifications(completionHandler: { [weak self] deliveredNotifications -> () in
            guard let self = self else { return }

            GigyaLogger.log(with: self, message: "\(deliveredNotifications.count) Delivered notifications-------")

            let modeString = userInfo["mode"] as? String ?? ""
            let mode = PushNotificationModes(rawValue: modeString) ?? .verify

            // delete push notification with cancel mode
            if mode == .cancel {
            // remove push by id
                for (identifier, notification) in deliveredNotifications {
                    if self.needToCancel(payloadToCompare: notification, payloadFromPush: userInfo)
                    {
                        self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
                    }
                }
            }

            // remove all nofitication when the session is not valid
            if self.sessionService.isValidSession() == false {
                for (identifier, notification) in deliveredNotifications {
                    if self.needToCancel(payloadToCompare: notification, payloadFromPush: notification)
                    {
                        self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
                    }
                }
            }

            completion(.newData)

        })
    }

    private func needToCancel(payloadToCompare: [AnyHashable : Any], payloadFromPush: [AnyHashable : Any]) -> Bool{
        for remoteId in handlersRegistry.keys {
            if let gid = payloadToCompare[remoteId] as? String,
                let idToDelete = payloadFromPush[remoteId] as? String,
                gid == idToDelete
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

        guard let pushToken = pushToken, sessionService.isValidSession() == true, pushToken != key else {
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
        handlersRegistry.forEach { (handler) in
            if let key = response[handler.key] as? String, !key.isEmpty {
                handler.value(response)
            }
        }
    }
}

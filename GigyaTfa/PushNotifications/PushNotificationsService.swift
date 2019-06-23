//
//  PushNotificationsService.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 16/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya
import GigyaInfra

@available(iOS 10.0, *)
class PushNotificationsService: NSObject, IOCPushNotificationsService {

    let container: IOCContainer

    let apiService: IOCApiServiceProtocol

    let pushSaveKey = "com.gigya.GigyaTfa:pushKey"

    let pushAllowed = "com.gigya.GigyaTfa:pushKey"

    var pushOptIn: PushTfaOptIn?

    required override init() {
        self.container = Gigya.getContainer()
        self.apiService = container.resolve(IOCApiServiceProtocol.self)!

        super.init()
    }

    private var pushToken: String? {
        didSet {
            sendPushKeyIfNeeded()
        }
    }

    func onRecivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { deliveredNotifications -> () in

            GigyaLogger.log(with: self, message: "\(deliveredNotifications.count) Delivered notifications-------")

            // remove push by id
            for notification in deliveredNotifications {
                if let gid = notification.request.content.userInfo["gcm.message_id"] as? String,
                    let idToDelete = userInfo["getId"] as? String,
                    gid.contains(idToDelete)
                {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                }


                print(notification.request.identifier)
            }

            completion(.newData)

        })
    }

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

    func savePushKey(key: String) {
        pushToken = key
    }

    func optInToPushTfa(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        registerForPushNotifications { [weak self] success in
            guard let self = self, success == true else { return }


            self.pushOptIn = PushTfaOptIn(apiService: self.apiService, completion: completion)
            self.pushOptIn?.pushToken = self.pushToken

            self.pushOptIn?.start()
        }
    }

    private func sendPushKeyIfNeeded() {
        let key = UserDefaults.standard.object(forKey: pushSaveKey) as? String ?? ""

        guard let pushToken = pushToken, GigyaInfra.isSessionValid() == true else { return } // TODO: add session validation

        guard !pushToken.contains(key) else {
            return
        }

        let model = ApiRequestModel(method: "accounts.auth.push.updateDevice", params: ["platform": "ios", "os": GeneralUtils.iosVersion(), "man": "apple", "pushToken": pushToken])

        apiService.send(model: model, responseType: GigyaDictionary.self) { result in
            switch result {
            case .success:
                UserDefaults.standard.set(pushToken, forKey: self.pushSaveKey)
                UserDefaults.standard.synchronize()
            case .failure(let error):
                GigyaLogger.log(with: self, message: error.localizedDescription)
            }
        }

    }

    func verifyPushTfa(userInfo: [AnyHashable : Any]) {
        let title = userInfo["title"] as? String ?? ""
        let msg = userInfo["body"] as? String ?? ""
        let modeString = userInfo["mode"] as? String ?? "verify"
        let verificationToken = userInfo["verificationToken"] as? String ?? ""
        let gigyaAssertion = userInfo["gigyaAssertion"] as? String ?? ""

        let mode = PushNotificationModes(rawValue: modeString) ?? PushNotificationModes.verify

        AlertControllerUtils.show(title: title, message: msg) { [weak self] isApproved in
            if isApproved == true {
                switch mode {
                case .optin:
                    self?.pushOptIn?.verifyOptIn(verificationToken: verificationToken)
                case .verify:
                    self?.completeVerification(gigyaAssertion: gigyaAssertion, verificationToken: verificationToken)
                case .remove:
                    break
                }
            }
        }
    }

    private func completeVerification(gigyaAssertion: String, verificationToken: String) {
        let model = ApiRequestModel(method: "accounts.tfa.push.verify", params: ["gigyaAssertion": gigyaAssertion, "verificationToken": verificationToken])

        apiService.send(model: model, responseType: GigyaDictionary.self) { result in
            switch result {
            case .success:
                GigyaLogger.log(with: self, message: "completeVerification - success")
            case .failure(let error):
                GigyaLogger.log(with: self, message: error.localizedDescription)
            }
        }
    }
}

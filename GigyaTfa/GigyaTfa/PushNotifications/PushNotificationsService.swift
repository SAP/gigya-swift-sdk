//
//  PushNotificationsService.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 16/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya

@available(iOS 10.0, *)
class PushNotificationsService: NSObject, PushNotificationsServiceProtocol {

    let container: IOCContainer

    let apiService: ApiServiceProtocol

    let sessionService: SessionServiceProtocol

    let biometricService: BiometricServiceProtocol

    // User defaults params
    let pushSaveKey = "com.gigya.GigyaTfa:pushKey"

    let pushAllowed = "com.gigya.GigyaTfa:pushKey"

    var pushOptIn: PushTfaOptInService?

    required override init() {
        self.container = Gigya.getContainer()
        self.apiService = container.resolve(ApiServiceProtocol.self)!
        self.sessionService = container.resolve(SessionServiceProtocol.self)!
        self.biometricService = container.resolve(BiometricServiceProtocol.self)!

        super.init()
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

    func optInToPushTfa(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        registerForPushNotifications { [weak self] success in
            guard let self = self, success == true else { return }

            self.pushOptIn = PushTfaOptInService(apiService: self.apiService, completion: completion)
            self.pushOptIn?.pushToken = self.pushToken

            self.pushOptIn?.start()
        }
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

    // MARK: Verification push Tfa

    func verifyPushTfa(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        let title = userInfo["title"] as? String ?? ""
        let msg = userInfo["body"] as? String ?? ""
        let modeString = userInfo["mode"] as? String ?? ""
        let verificationToken = userInfo["verificationToken"] as? String ?? ""
        let gigyaAssertion = userInfo["gigyaAssertion"] as? String ?? ""

        let mode = PushNotificationModes(rawValue: modeString) ?? PushNotificationModes.cancel
        if mode == .cancel {
            return
        }

        let completeVerificationFlow = { [weak self] in
            switch mode {
            case .optin:
                self?.pushOptIn?.verifyOptIn(verificationToken: verificationToken)
            case .verify:
                self?.completeVerification(gigyaAssertion: gigyaAssertion, verificationToken: verificationToken)
            case .cancel:
                break
            }
        }

        if biometricService.isOptIn {
            biometricService.unlockSession { (result) in
                switch result {
                case .success:
                    AlertControllerUtils.show(title: title, message: msg) { isApproved in
                        if isApproved == true {
                            completeVerificationFlow()
                        }
                    }
                case .failure:
                    GigyaLogger.log(with: self, message: "can't unlock session")
                }
            }
        } else {
            completeVerificationFlow()
        }

    }

    private func completeVerification(gigyaAssertion: String, verificationToken: String) {
        let model = ApiRequestModel(method: GigyaDefinitions.API.pushVerifyTFA, params: ["gigyaAssertion": gigyaAssertion, "verificationToken": verificationToken])

        apiService.send(model: model, responseType: GigyaDictionary.self) { result in
            switch result {
            case .success:
                GigyaLogger.log(with: self, message: "completeVerification - success")

                GeneralUtils.showNotification(title: "Verify push TFA", body: "Successfully authenticated login request", id: "completeVerification")


            case .failure(let error):
                GigyaLogger.log(with: self, message: error.localizedDescription)
            }
        }
    }
}

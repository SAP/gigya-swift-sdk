//
//  PushLoginManager.swift
//  GigyaAuth
//
//  Created by Shmuel, Sagi on 20/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya

@available(iOS 10.0, *)
final class PushLoginManager: NSObject, BasePushManagerProtocol {

    let container: IOCContainer

    let apiService: ApiServiceProtocol

    let sessionService: SessionServiceProtocol

    let pushService: PushNotificationsServiceExternalProtocol

    let biometricService: BiometricServiceProtocol

    let generalUtils: GeneralUtils

    let idintityKey: String = "vToken"

    required init(container: IOCContainer) {
        self.container = container
        self.apiService = container.resolve(ApiServiceProtocol.self)!
        self.sessionService = container.resolve(SessionServiceProtocol.self)!
        self.pushService = container.resolve(PushNotificationsServiceExternalProtocol.self)!
        self.biometricService = container.resolve(BiometricServiceProtocol.self)!
        self.generalUtils = container.resolve(GeneralUtils.self)!

        super.init()

        registerToService()
    }

    private func registerToService() {
        pushService.registerTo(key: idintityKey) { [weak self] msg in
            self?.verifyPushLogin(response: msg)
        }
    }

    // MARK: Register to push login

    func beforeRegisterDeviceToPushLogin(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        pushService.registerForPushNotifications { [weak self] success in
            guard let self = self, success == true else {
                completion(.failure(.providerError(data: "Permission denied - push notificiations not allowed")))
                return
            }

            self.registerDeviceToPushLogin(completion: completion)
        }
    }

    private func registerDeviceToPushLogin(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        guard let pushToken = self.pushService.getPushToken() else {
            completion(.failure(.providerError(data: "push token not exists")))
            return
        }

        let deviceInfo = ["platform": "ios", "os": generalUtils.iosVersion(), "man": "apple", "pushToken": pushToken]
        let model = ApiRequestModel(method: GigyaDefinitions.API.pushOptinLogin, params: ["deviceInfo": deviceInfo])

        apiService.send(model: model, responseType: GigyaDictionary.self) { result in
            switch result {
            case .success(let data):
                // Success
                completion(.success(data: data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Verification push login

    func verifyPushLogin(response: [AnyHashable : Any]) {
        let userInfo = response

        guard let type = userInfo["type"] as? String, type == "AuthChallenge" else {
            return
        }

        let title = userInfo["title"] as? String ?? ""
        let msg = userInfo["body"] as? String ?? ""
        let modeString = userInfo["mode"] as? String ?? ""
        let verificationToken = userInfo["vToken"] as? String ?? ""

        let mode = PushNotificationModes(rawValue: modeString) ?? PushNotificationModes.cancel
        if mode == .cancel {
            return
        }

        let completeVerificationFlow = { [weak self] in
            guard let topVireController = self?.generalUtils.getTopViewController() else {
                return
            }

            self?.generalUtils.show(vc: topVireController, title: title, message: msg) { [weak self] isApproved in
                if isApproved == true {
                    switch mode {
                    case .verify:
                        self?.completeVerification(verificationToken: verificationToken)
                    case .cancel, .optin:
                        break
                    }
                }
            }
        }
        
        if biometricService.isOptIn {
            DispatchQueue.main.async { [weak self] in
                self?.biometricService.unlockSession { (result) in
                    switch result {
                    case .success:
                        completeVerificationFlow()
                    case .failure:
                        GigyaLogger.log(with: self, message: "can't unlock session")
                    }
                }
            }
        } else {
            completeVerificationFlow()
        }
    }

    private func completeVerification(verificationToken: String) {
        let model = ApiRequestModel(method: GigyaDefinitions.API.pushVerifyLogin, params: ["vToken": verificationToken])

        apiService.send(model: model, responseType: GigyaDictionary.self) { [weak self] result in
            switch result {
            case .success:
                GigyaLogger.log(with: self, message: "completeVerification - success")

                self?.generalUtils.showNotification(title: "Verify push Login", body: "Successfully authenticated login request", id: "completeVerification")

            case .failure(let error):
                GigyaLogger.log(with: self, message: error.localizedDescription)
            }
        }
    }
}

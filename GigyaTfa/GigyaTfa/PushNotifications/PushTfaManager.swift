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
final class PushTfaManager: NSObject, PushTfaManagerProtocol, BasePushManagerProtocol {

    let container: IOCContainer

    let apiService: ApiServiceProtocol

    let sessionService: SessionServiceProtocol

    let biometricService: BiometricServiceProtocol

    let pushService: PushNotificationsServiceExternalProtocol

    let generalUtils: GeneralUtils

    var pushOptIn: PushTfaOptInService?

    let idintityKey: String = "vToken"

    required override init() {
        self.container = Gigya.getContainer()
        self.apiService = container.resolve(ApiServiceProtocol.self)!
        self.sessionService = container.resolve(SessionServiceProtocol.self)!
        self.biometricService = container.resolve(BiometricServiceProtocol.self)!
        self.pushService = container.resolve(PushNotificationsServiceExternalProtocol.self)!
        self.generalUtils = container.resolve(GeneralUtils.self)!

        super.init()
        
        registerToService()
    }

    private func registerToService() {
        pushService.registerTo(key: idintityKey) { [weak self] msg in
            self?.verifyPushTfa(response: msg)
        }
    }

    // MARK: Opt in to push tfa

    func optInToPushTfa(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        pushService.registerForPushNotifications { [weak self] success in
            guard let self = self, success == true else { return }

            self.pushOptIn = PushTfaOptInService(apiService: self.apiService, generalUtils: self.generalUtils, completion: completion)
            self.pushOptIn?.pushToken = self.pushService.getPushToken()

            self.pushOptIn?.start()
        }
    }


    // MARK: Verification push Tfa

    func verifyPushTfa(response: [AnyHashable : Any]) {
        let userInfo = response

        // allow to verify tfa only when have gigyaAssertion
        guard let gigyaAssertion = userInfo["gigyaAssertion"] as? String else {
            return
        }

        let title = userInfo["title"] as? String ?? ""
        let msg = userInfo["body"] as? String ?? ""
        let modeString = userInfo["mode"] as? String ?? ""
        let verificationToken = userInfo["verificationToken"] as? String ?? ""

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
                    case .optin:
                        self?.pushOptIn?.verifyOptIn(verificationToken: verificationToken)
                    case .verify:
                        self?.completeVerification(gigyaAssertion: gigyaAssertion, verificationToken: verificationToken)
                    case .cancel:
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

    private func completeVerification(gigyaAssertion: String, verificationToken: String) {
        let model = ApiRequestModel(method: GigyaDefinitions.API.pushVerifyTFA, params: ["gigyaAssertion": gigyaAssertion, "verificationToken": verificationToken])

        apiService.send(model: model, responseType: GigyaDictionary.self) { [weak self] result in
            switch result {
            case .success:
                GigyaLogger.log(with: self, message: "completeVerification - success")

                self?.generalUtils.showNotification(title: "Verify push TFA", body: "Successfully authenticated login request", id: "completeVerification")

            case .failure(let error):
                GigyaLogger.log(with: self, message: error.localizedDescription)
            }
        }
    }
}

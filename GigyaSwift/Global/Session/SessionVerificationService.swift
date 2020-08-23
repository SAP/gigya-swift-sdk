//
//  SessionVerificationService.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 26/12/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

protocol SessionVerificationServiceProtocol {
    init(config: GigyaConfig, apiService: ApiServiceProtocol, sessionService: SessionServiceProtocol, businessApi: BusinessApiServiceProtocol)

    func registerAppStateEvents()

    func stop()
}

class SessionVerificationService: SessionVerificationServiceProtocol {

    private let config: GigyaConfig

    let apiService: ApiServiceProtocol

    let sessionService: SessionServiceProtocol

    let businessApi: BusinessApiServiceProtocol

    private var sessionLifeCountdownTimer: Timer?

    required init(config: GigyaConfig, apiService: ApiServiceProtocol, sessionService: SessionServiceProtocol, businessApi: BusinessApiServiceProtocol) {
        self.config = config
        self.apiService = apiService
        self.sessionService = sessionService
        self.businessApi = businessApi
    }

    func registerAppStateEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appReturnToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        sessionService.handlersAfterSetSession.add(key: "SessionVerificationService", handler: startSessionCountdownTimerIfNeeded)

        startSessionCountdownTimerIfNeeded()
    }

    private func unregisterAppStateEvents() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func appMovedToBackground() {
        stop()

        GigyaLogger.log(with: self, message: "stop: app going to backgroud")
    }

    @objc func appReturnToForeground() {
        startSessionCountdownTimerIfNeeded()
    }

    func startSessionCountdownTimerIfNeeded() {
        guard sessionService.isValidSession() else {
            GigyaLogger.log(with: self, message: "start: Verification can't run, session not valid")
            return
        }

        guard let timeInterval = config.sessionVerificationInterval, timeInterval != 0 else {
            GigyaLogger.log(with: self, message: "start: Verification interval is 0. Verification flow irrelevant")
            return
        }

        GigyaLogger.log(with: self, message: "start: Verification interval is \(timeInterval) seconds")

        start(with: timeInterval)
    }

    func start(with timeInterval: Double) {
        sessionLifeCountdownTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }

            let reqModel = ApiRequestModel(method: GigyaDefinitions.API.verifyLogin, params: ["include": "identities-all,loginIDs,profile,email,data"], isAnonymous: true)

            self.apiService.send(model: reqModel, responseType: GigyaDictionary.self, completion: { (result) in
                switch result {
                case .success:
                    GigyaLogger.log(with: self, message: "verifyLogin success")
                case .failure(let error):
                    self.evaluateVerifyLoginError(error)
                }
            })
        })
    }

    func stop() {
        sessionLifeCountdownTimer?.invalidate()
    }

    private func evaluateVerifyLoginError(_ error: NetworkError) {
        if case .gigyaError(let errorData) = error {
            GigyaLogger.log(with: self, message: "evaluateVerifyLoginError: error = \(errorData.errorCode) session invalid -> invalidate & notify")

            notifyInvalidSession(errorData: errorData)
        }
    }

    private func notifyInvalidSession(errorData: GigyaResponseModel) {
        GigyaLogger.log(with: self, message: "notifyInvalidSession: Invalidating session and cached account. Trigger local broadcast")

        // stop timer
        stop()

        // do logout
        businessApi.logout { _ in }

        // send message to the host
        NotificationCenter.default.post(name: .didInvalidateSession, object: nil, userInfo: errorData.toDictionary())
    }
}

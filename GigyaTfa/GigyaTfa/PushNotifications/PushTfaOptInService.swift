//
//  PushOptIn.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 17/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya

protocol PushTfaOptInServiceProtocol {
    var gigyaAssertion: String? { get set }

    var regToken: String? { get set }

    var pushToken: String? { get set } // only in push tfa

    func start()
}

final class PushTfaOptInService: PushTfaOptInServiceProtocol {
    let apiService: ApiServiceProtocol

    let generalUtils: GeneralUtils

    var gigyaAssertion: String?

    var regToken: String?

    var pushToken: String?

    var completion: (GigyaApiResult<GigyaDictionary>) -> Void = { _ in }

    init(apiService: ApiServiceProtocol, generalUtils: GeneralUtils, completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        self.apiService = apiService
        self.completion = completion
        self.generalUtils = generalUtils
    }

    func start() {
        initTFA(mode: .register)
    }

    func initTFA(tfaProvider: TFAProvider = .push, mode: TFAMode, arguments: [String: String] = [:]) {
        var params = ["provider" : tfaProvider.rawValue, "mode": mode.rawValue]

        if let regToken = regToken {
            params["regToken"] = regToken
        }

        let model = ApiRequestModel(method: GigyaDefinitions.API.initTFA, params: params)
        apiService.send(model: model, responseType: InitTFAModel.self) { [weak self] result in
            switch result {
            case .success(let data):
                guard let gigyaAssertion = data.gigyaAssertion else {
                    self?.completion(.failure(.emptyResponse))
                    return
                }

                self?.gigyaAssertion = gigyaAssertion

                self?.callOptIn()
                
            case .failure(let error):
                self?.completion(.failure(error))
            }
        }
    }

    private func callOptIn() {
        guard let pushToken = pushToken , let gigyaAssertion = self.gigyaAssertion else {
            return
        }

        let deviceInfo = ["platform": "ios", "os": generalUtils.iosVersion(), "man": "apple", "pushToken": pushToken]
        let model = ApiRequestModel(method: GigyaDefinitions.API.pushOptinTFA, params: ["gigyaAssertion": gigyaAssertion ,"deviceInfo": deviceInfo])

        apiService.send(model: model, responseType: GigyaDictionary.self) { [weak self] result in
            switch result {
            case .success(let data):
                // Success
                self?.completion(.success(data: data))
            case .failure(let error):
                self?.completion(.failure(error))
            }
        }

    }

    func verifyOptIn(verificationToken: String) {
        guard let gigyaAssertion = self.gigyaAssertion else {
            return
        }

        let model = ApiRequestModel(method: "accounts.tfa.push.verify", params: ["gigyaAssertion": gigyaAssertion, "verificationToken": verificationToken])

        apiService.send(model: model, responseType: GigyaDictionary.self) { [weak self] (result) in
            switch result {
            case .success(let data):
                let providerAssertion = data["providerAssertion"]?.value as? String ?? ""

                self?.finalizeTFA(providerAssertion: providerAssertion)
            case .failure(let error):
                self?.completion(.failure(error))
            }
        }
    }

    func finalizeTFA(providerAssertion: String) {
        guard let gigyaAssertion = self.gigyaAssertion else {
            return
        }

        let model = ApiRequestModel(method: "accounts.tfa.finalizeTFA", params: ["gigyaAssertion": gigyaAssertion, "providerAssertion": providerAssertion])

        apiService.send(model: model, responseType: GigyaDictionary.self) { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.generalUtils.showNotification(title: "Opt-In for push TFA", body: "This device is now registered for push TFA", id: "verifyOptIn")
                
                self?.completion(.success(data: data))
            case .failure(let error):
                self?.completion(.failure(error))
            }
        }
    }
}

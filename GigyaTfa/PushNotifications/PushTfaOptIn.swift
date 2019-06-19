//
//  PushOptIn.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 17/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

protocol RegisterTfaProtocol {
    var gigyaAssertion: String? { get set }

    var regToken: String? { get set }

    var pushToken: String? { get set } // only in push tfa

    func start()
}

class PushTfaOptIn: RegisterTfaProtocol {
    let apiService: IOCApiServiceProtocol

    var gigyaAssertion: String?

    var regToken: String?

    var pushToken: String?

    var completion: (Bool) -> Void = { _ in }

    init(apiService: IOCApiServiceProtocol) {
        self.apiService = apiService
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
                    self?.completion(false)
                    return
                }

                self?.gigyaAssertion = gigyaAssertion

                self?.callOptIn()
            case .failure:
                self?.completion(false)
            }
        }
    }

    private func callOptIn() {
        guard let pushToken = pushToken , let gigyaAssertion = self.gigyaAssertion else {
            return
        }
        
        let model = ApiRequestModel(method: "accounts.auth.push.optin", params: ["gigyaAssertion": gigyaAssertion ,"deviceInfo": ["platform": "ios", "os": GeneralUtils.iosVersion(), "man": "apple", "pushToken": pushToken]])

        apiService.send(model: model, responseType: GigyaResponseModel.self) { [weak self] result in
            switch result {
            case .success:
                // Success
                self?.completion(true)
            case .failure:
                self?.completion(false)
            }
        }

    }
}

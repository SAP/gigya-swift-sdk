//
//  VerifyCodeResolver.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 24/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

final class VerifyCodeResolver<T: GigyaAccountProtocol>: TFAResolver<T>, VerifyCodeResolverProtocol {
    private var phvToken: String?

    internal let businessApiDelegate: BusinessApiDelegate
    internal let interruption: GigyaResponseModel
    internal let completionHandler: (GigyaLoginResult<T>) -> Void

    required init(businessApiDelegate: BusinessApiDelegate, interruption: GigyaResponseModel, completionHandler: @escaping (GigyaLoginResult<T>) -> Void) {
        self.businessApiDelegate = businessApiDelegate
        self.interruption = interruption
        self.completionHandler = completionHandler

        super.init(businessApiDelegate: businessApiDelegate, interruption: interruption, completionHandler: completionHandler)

    }
    
    func setAssertionAndPhvToken(gigyaAssertion: String, phvToken: String) {
        self.gigyaAssertion = gigyaAssertion
        self.phvToken = phvToken
    }

    func finalizeTfa(providerAssertion: String, rememberDevice: Bool, completion: @escaping (VerifyCodeResultCallback) -> Void) {
        var params = ["regToken": self.regToken, "gigyaAssertion": self.gigyaAssertion, "providerAssertion": providerAssertion] as! [String: String]

        if rememberDevice == true {
            params["tempDevice"] = "false"
        }

        businessApiDelegate.sendApi(api: GigyaDefinitions.API.finalizeTFA, params: params) { [weak self] result in
            switch result {
            case .success:
                if let self = self  {
                    // Finalize the registration process & complete the flow.
                    let clousre: (GigyaLoginResult<T>) -> Void = { [weak self] result in
                        switch result {
                        case .success:
                            completion(.resolved)
                        case .failure(let error):
                            completion(.failed(error.error))
                        }

                        self?.completionHandler(result)
                    }
                    
                    self.businessApiDelegate.callfinalizeRegistration(regToken: self.regToken, completion: clousre)
                }
            case .failure(let error):
                completion(.failed(error))
            }
        }
    }

    public func verifyCode(provider: TFAProvider, verificationCode: String, rememberDevice: Bool, completion: @escaping (VerifyCodeResultCallback) -> Void) {
        guard let gigyaAssertion = self.gigyaAssertion, let phvToken = self.phvToken else {
            completion(.failed(.emptyResponse))
            return
        }

        let params = ["gigyaAssertion": gigyaAssertion, "code": verificationCode, "phvToken": phvToken]

        let api: String

        switch provider {
        case .phone, .liveLink:
            api = GigyaDefinitions.API.phoneCompleteVerificationTFA
        case .email:
            api = GigyaDefinitions.API.emailCompleteVerificationTFA
        default:
            return
        }

        businessApiDelegate.sendApi(dataType: TFACompleteVerificationModel.self, api: api, params: params, completion: { [weak self] result in
            switch result {
            case .success(let data):
                guard let providerAssertion = data.providerAssertion else {
                    completion(.failed(.emptyResponse))
                    return
                }

                self?.finalizeTfa(providerAssertion: providerAssertion, rememberDevice: rememberDevice, completion: completion)
            case .failure(let error):
                if case .gigyaError(let data) = error, data.errorCode == GigyaDefinitions.ErrorCode.invalidJwt {
                    completion(.invalidCode)
                    return
                }

                completion(.failed(error))
            }
        })
    }
}

@frozen
public enum VerifyCodeResultCallback {
    case resolved
    case invalidCode
    case failed(NetworkError)
}

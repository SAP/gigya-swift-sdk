//
//  VerifyTotpResolver.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 24/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Gigya

final public class VerifyTotpResolver<T: GigyaAccountProtocol>: TFAResolver<T>, VerifyTotpResolverProtocol, TFAResolversProtocol {
    private var sctToken: String?

    internal let businessApiDelegate: BusinessApiDelegate
    internal let interruption: GigyaResponseModel
    internal let completionHandler: (GigyaLoginResult<T>) -> Void

    lazy var verifyCodeResolver: VerifyCodeResolver = {
        return VerifyCodeResolver(businessApiDelegate: self.businessApiDelegate, interruption: self.interruption, completionHandler: self.completionHandler)
    }()

    required init(businessApiDelegate: BusinessApiDelegate, interruption: GigyaResponseModel, completionHandler: @escaping (GigyaLoginResult<T>) -> Void) {
        self.businessApiDelegate = businessApiDelegate
        self.interruption = interruption
        self.completionHandler = completionHandler

        super.init(businessApiDelegate: businessApiDelegate, interruption: interruption, completionHandler: completionHandler)
    }

    func setAssertionAndSctToken(gigyaAssertion: String, sctToken: String) {
        self.gigyaAssertion = gigyaAssertion
        self.sctToken = sctToken
    }

    public func verifyTOTPCode(verificationCode: String, rememberDevice: Bool, completion: @escaping (VerifyCodeResultCallback) -> Void ) {
        if sctToken == nil {
            restartVerificationFlow(verificationCode: verificationCode, rememberDevice: rememberDevice, completion: completion)
        } else {
            completeVerification(verificationCode: verificationCode, rememberDevice: rememberDevice, completion: completion)
        }
    }

    private func restartVerificationFlow(verificationCode: String, rememberDevice: Bool, completion: @escaping (VerifyCodeResultCallback) -> Void ) {
        var params: [String: String] = [:]
        params["regToken"] = self.regToken
        params["provider"] = TFAProvider.totp.rawValue
        params["mode"] = TFAMode.verify.rawValue

        businessApiDelegate.sendApi(dataType: InitTFAModel.self, api: GigyaDefinitions.API.initTFA, params: params) { [weak self] result in
            switch result {
            case .success(let data):
                self?.gigyaAssertion = data.gigyaAssertion

                self?.completeVerification(verificationCode: verificationCode, rememberDevice: rememberDevice, completion: completion)
            case .failure(let error):
                completion(.failed(error))
            }
        }
    }

    private func completeVerification(verificationCode: String, rememberDevice: Bool, completion: @escaping (VerifyCodeResultCallback) -> Void ) {
        var params: [String: String] = [:]
        params["gigyaAssertion"] = self.gigyaAssertion
        params["code"] = verificationCode

        if let sctToken = sctToken {
            params["sctToken"] = sctToken
        }

        businessApiDelegate.sendApi(dataType: TFACompleteVerificationModel.self, api: GigyaDefinitions.API.totpVerifyTFA, params: params) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                guard let providerAssertion = data.providerAssertion else {
                    completion(.failed(.emptyResponse))
                    return
                }

                self.finalizeTFA(providerAssertion: providerAssertion, rememberDevice: rememberDevice, completion: completion)

            case .failure(let error):
                completion(.failed(error))
            }
        }
    }

    private func finalizeTFA(providerAssertion: String, rememberDevice: Bool, completion: @escaping (VerifyCodeResultCallback) -> Void) {
        var params: [String: String] = [:]
        params["gigyaAssertion"] = self.gigyaAssertion
        params["regToken"] = self.regToken
        params["providerAssertion"] = providerAssertion

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
}

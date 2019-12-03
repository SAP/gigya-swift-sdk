//
//  RegisterPhoneResolver.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 24/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

final public class RegisterPhoneResolver<T: GigyaAccountProtocol>: TFAResolver<T>, RegisterPhonesResolverProtocol, TFAResolversProtocol {

    internal let businessApiDelegate: BusinessApiDelegate
    internal let interruption: GigyaResponseModel
    internal let completionHandler: (GigyaLoginResult<T>) -> Void

    private var provider: TFAProvider = .phone

    lazy var verifyCodeResolver: VerifyCodeResolver = {
        return VerifyCodeResolver(businessApiDelegate: self.businessApiDelegate, interruption: self.interruption, completionHandler: self.completionHandler)
    }()

    required init(businessApiDelegate: BusinessApiDelegate, interruption: GigyaResponseModel, completionHandler: @escaping (GigyaLoginResult<T>) -> Void) {
        self.businessApiDelegate = businessApiDelegate
        self.interruption = interruption
        self.completionHandler = completionHandler

        super.init(businessApiDelegate: businessApiDelegate, interruption: interruption, completionHandler: completionHandler)
    }

    public func provider(_ provider: TFAProvider) {
        self.provider = provider
    }

    public func registerPhone(phone: String, method: TFAPhoneMethod = .sms, lang: String = "en", completion: @escaping (RegisterPhonesResult) -> Void ) {
        var params: [String: String] = [:]
        params["regToken"] = self.regToken
        params["provider"] = provider.rawValue
        params["mode"] = TFAMode.register.rawValue

        businessApiDelegate.sendApi(dataType: InitTFAModel.self, api: GigyaDefinitions.API.initTFA, params: params) { [weak self] result in
            switch result {
            case .success(let data):
                self?.gigyaAssertion = data.gigyaAssertion

                self?.registerPhoneNumber(with: phone, method: method, lang: lang, completion: completion)
            case .failure(let error):
                completion(.error(error))
            }
        }
    }

    private func registerPhoneNumber(with phone: String, method: TFAPhoneMethod = .sms, lang: String, completion: @escaping (RegisterPhonesResult) -> Void) {
        var params: [String: String] = [:]
        params["phone"] = phone
        params["gigyaAssertion"] = self.gigyaAssertion
        params["method"] = method.rawValue
        params["lang"] = lang

        businessApiDelegate.sendApi(dataType: TFAVerificationCodeModel.self, api: GigyaDefinitions.API.sendVerificationCodeTFA, params: params) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                guard let phvToken = data.phvToken, let gigyaAssertion = self.gigyaAssertion else {
                    completion(.error(.emptyResponse))
                    return
                }

                self.verifyCodeResolver.setAssertionAndPhvToken(gigyaAssertion: gigyaAssertion, phvToken: phvToken)

                completion(.verificationCodeSent(resolver: self.verifyCodeResolver))
            case .failure(let error):
                completion(.error(error))
            }
        }
    }
}

public enum RegisterPhonesResult {
    case verificationCodeSent(resolver: VerifyCodeResolverProtocol)
    case error(NetworkError)
}



//
//  RegistredPhoneResolver.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 24/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

public class RegisteredPhonesResolver<T: GigyaAccountProtocol>: TFAResolver<T>, RegisteredPhonesResolverProtocol, TFAResolversProtocol {

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

    public func getRegisteredPhones(completion: @escaping (RegisteredPhonesResult) -> Void ) {
        var params: [String: String] = [:]
        params["regToken"] = self.regToken
        params["provider"] = provider.rawValue
        params["mode"] = TFAMode.verify.rawValue

        businessApiDelegate.sendApi(dataType: InitTFAModel.self, api: GigyaDefinitions.API.initTFA, params: params) { [weak self] result in
            switch result {
            case .success(let data):
                self?.gigyaAssertion = data.gigyaAssertion

                self?.fetchPhones(completion: completion)
            case .failure(let error):
                completion(.error(error))
            }
        }
    }

    private func fetchPhones(completion: @escaping (RegisteredPhonesResult) -> Void) {
        guard let gigyaAssertion = gigyaAssertion else {
            completion(.error(.emptyResponse))
            return
        }

        businessApiDelegate.sendApi(dataType: TFAGetRegisteredPhoneNumbersModel.self, api: GigyaDefinitions.API.getRegisteredPhoneNumbersTFA, params: ["gigyaAssertion": gigyaAssertion]) {result in
            switch result {
            case .success(let data):
                guard let phones = data.phones else  {
                    completion(.error(.emptyResponse))
                    return
                }

                completion(.registeredPhones(phones: phones))
            case .failure(let error):
                completion(.error(error))
            }
        }

    }

    public func sendVerificationCode(with phone: TFARegisteredPhone, method: TFAPhoneMethod, lang: String = "eng", completion: @escaping (RegisteredPhonesResult) -> Void) {
        var params: [String: String] = [:]
        params["phoneID"] = phone.id
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


public enum RegisteredPhonesResult {
    case registeredPhones(phones: [TFARegisteredPhone])
    case verificationCodeSent(resolver: VerifyCodeResolverProtocol)
    case error(NetworkError)
}


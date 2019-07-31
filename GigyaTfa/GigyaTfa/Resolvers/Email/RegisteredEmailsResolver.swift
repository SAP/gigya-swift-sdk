//
//  RegisteredEmailsResolver.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 23/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

public class RegisteredEmailsResolver<T: GigyaAccountProtocol>: TFAResolver<T>, RegisteredEmailsResolverProtocol, TFAResolversProtocol {

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

    public func getRegisteredEmails(completion: @escaping (RegisteredEmailsResult) -> Void ) {
        var params: [String: String] = [:]
        params["regToken"] = self.regToken
        params["provider"] = TFAProvider.email.rawValue
        params["mode"] = TFAMode.verify.rawValue

        businessApiDelegate.sendApi(dataType: InitTFAModel.self, api: GigyaDefinitions.API.initTFA, params: params) { [weak self] result in
            switch result {
            case .success(let data):
                self?.gigyaAssertion = data.gigyaAssertion

                self?.fetchEmails(completion: completion)
            case .failure(let error):
                completion(.error(error))
            }
        }
    }

    private func fetchEmails(completion: @escaping (RegisteredEmailsResult) -> Void) {
        guard let gigyaAssertion = gigyaAssertion else {
            completion(.error(.emptyResponse))
            return
        }

        businessApiDelegate.sendApi(dataType: TFAEmailsModel.self, api: GigyaDefinitions.API.getEmailsTFA, params: ["gigyaAssertion": gigyaAssertion]) {result in
            switch result {
            case .success(let data):
                guard let emails = data.emails else  {
                    completion(.error(.emptyResponse))
                    return
                }

                completion(.registeredEmails(emails: emails))
            case .failure(let error):
                completion(.error(error))
            }
        }

    }

    public func sendEmailCode(with email: TFAEmail, lang: String = "eng", completion: @escaping (RegisteredEmailsResult) -> Void) {
        var params: [String: String] = [:]
        params["emailID"] = email.id
        params["gigyaAssertion"] = self.gigyaAssertion
        params["lang"] = lang

        businessApiDelegate.sendApi(dataType: TFAVerificationCodeModel.self, api: GigyaDefinitions.API.emailSendVerificationCodeTFA, params: params) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                guard let phvToken = data.phvToken, let gigyaAssertion = self.gigyaAssertion else {
                    completion(.error(.emptyResponse))
                    return
                }

                self.verifyCodeResolver.setAssertionAndPhvToken(gigyaAssertion: gigyaAssertion, phvToken: phvToken)

                completion(.emailVerificationCodeSent(resolver: self.verifyCodeResolver))
            case .failure(let error):
                completion(.error(error))
            }
        }
    }
    
}


public enum RegisteredEmailsResult {
    case registeredEmails(emails: [TFAEmail])
    case emailVerificationCodeSent(resolver: VerifyCodeResolverProtocol)
    case error(NetworkError)
}


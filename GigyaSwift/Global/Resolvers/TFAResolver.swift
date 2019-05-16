//
//  TFAResolver.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 15/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public enum TFAProvider: String {
    case gigyaPhone = "gigyaPhone"
    case email = "gigyaEmail"
    case totp = "gigyaTotp"
}

public class TFAResolver<T: Codable> : BaseResolver {
    
    let originalError: NetworkError
    
    let regToken: String
    
    weak var businessDelegate: BusinessApiDelegate?
    
    let completion: (GigyaLoginResult<T>) -> Void
    
    public var providers = [TFAProviderModel]()
    
    internal var gigyaAssertion: String?
    
    internal var phvToken: String?
    
    internal var sctToken: String?
    
    init(originalError: NetworkError, regToken: String, businessDelegate: BusinessApiDelegate, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        self.originalError = originalError
        self.regToken = regToken
        self.completion = completion
        self.businessDelegate = businessDelegate
        
        getTFAProviders()
    }
    
    private func getTFAProviders() {
        let params = ["regToken": self.regToken]
        self.businessDelegate?.sendApi(dataType: TFAProvidersModel.self,  api: GigyaDefinitions.API.tfaGetProviders, params: params) { [weak self] result in
            switch result {
            case .success(let data):
                // Evaluate available providers.
                if let activeProviders = data.activeProviders {
                    if !activeProviders.isEmpty {
                        self?.providers = activeProviders
                    }
                }
                if let inactiveProviders = data.inactiveProviders {
                    if !inactiveProviders.isEmpty {
                        self?.providers = inactiveProviders
                    }
                }
                
                self?.forwardInitialInterruption();
            case .failure(let error):
                
                self?.forwardError(error: error)
            }
        }
    }
    
    internal func forwardInitialInterruption() {
        // Stub. Will be overriden by child resolver.
    }
    
    /*
     Use for all intermediate errors. Will forward the error to the user and break the resolver flow.
     */
    private func forwardError(error: NetworkError) {
        let loginError = LoginApiError<T>(error: error, interruption: nil)
        self.completion(.failure(loginError))
    }
    
    /*
     Forwarding a general error that breaks the flow.
     */
    private func forwardGeneralError() {
        let error = NetworkError.dataNotFound
        let loginError = LoginApiError<T>(error: error, interruption: nil)
        self.completion(.failure(loginError))
    }
    
    //MARK: - TFA common flow.
    
    internal func initTFA(tfaProvider: TFAProvider, mode: String, arguments: [String: Any]) {
        let params = ["regToken": self.regToken, "provider" : tfaProvider.rawValue, "mode": mode]
        self.businessDelegate?.sendApi(dataType: InitTFAModel.self, api: GigyaDefinitions.API.initTFA, params: params) { [weak self] result in
            switch result {
            case .success(let data):
                guard let gigyaAssertion = data.gigyaAssertion else {
                    self?.forwardGeneralError()
                    return
                }
                self?.gigyaAssertion = gigyaAssertion
                switch tfaProvider {
                case .gigyaPhone:
                    self?.onTfaInitializedWithPhoneProvider(mode: mode, arguments: arguments)
                case .email:
                    self?.onTfaInitializedWithEmailProvider()
                    break
                case .totp:
                    break
                }
                break
            case .failure(let error):
                
                self?.forwardError(error: error)
                break
            }
        }
    }
    
    internal func verifyAuthorizationCode(api: String, params: [String: String]) {
        self.businessDelegate?.sendApi(dataType: TFACompleteVerificationModel.self, api: api, params: params, completion: { [weak self] result in
            switch result {
            case .success(let data):
                guard let providerAssertion = data.providerAssertion else {
                    self?.forwardGeneralError()
                    return
                }
                self?.finalizeTfa(providerAssertion: providerAssertion)
            case .failure(let error):
                self?.forwardError(error: error)
            }
        })
    }
    
    internal func finalizeTfa(providerAssertion: String) {
        let params = ["regToken": self.regToken, "gigyaAssertion": self.gigyaAssertion, "providerAssertion": providerAssertion] as! [String: String]
        self.businessDelegate?.sendApi(api: GigyaDefinitions.API.finalizeTFA, params: params) { [weak self] result in
            switch result {
            case .success(_):
                
                if let self = self  {
                    // Finalize the registration process & complete the flow.
                    self.businessDelegate?.callfinalizeRegistration(regToken: self.regToken, completion: self.completion)
                }
            case .failure(let error):
                
                self?.forwardError(error: error)
            }
        }
    }
    
    // MARK: - Gigya phone provider specific flow.
    
    internal func onTfaInitializedWithPhoneProvider(mode: String, arguments: [String: Any]) {
        switch mode {
        case "register":
            let number = arguments["phoneNumber"] as! String
            let method = arguments["method"] as! String
            
            self.sendPhoneVerificationCode(number: number, method: method)
        case "verify":
            
            self.getRegisteredPhoneNumbers()
            break
        default:
            break
        }
    }
    
    
    internal func sendPhoneVerificationCode(number: String = "", phoneId: String = "",  method: String) {
        var params = ["gigyaAssertion": self.gigyaAssertion, "method": method, "lang": "eng"] as! [String: String]
        if !number.isEmpty  {
            params["phone"] = number
        }
        if !phoneId.isEmpty {
            params["phoneID"] = phoneId
        }
        self.businessDelegate?.sendApi(dataType: TFAVerificationCodeModel.self, api: GigyaDefinitions.API.sendVerificationCodeTFA, params: params)
        { [weak self] result in
            switch result {
            case .success(let data):
                self?.phvToken = data.phvToken
                guard let originalError = self?.originalError else {
                    self?.forwardGeneralError()
                    return
                }
                let loginError = LoginApiError<T>(error: originalError, interruption: .onPhoneVerificationCodeSent)
                
                self?.completion(.failure(loginError))
            case .failure(let error):
               
                self?.forwardError(error: error)
            }
        }
    }
    
    internal func getRegisteredPhoneNumbers() {
        guard let gigyaAssertion = self.gigyaAssertion else {
            forwardGeneralError()
            return
        }
        self.businessDelegate?.sendApi(dataType: TFAGetRegisteredPhoneNumbersModel.self, api: GigyaDefinitions.API.getRegisteredPhoneNumbersTFA, params: ["gigyaAssertion": gigyaAssertion]) {
            [weak self] result in
            switch result {
            case .success(let data):
                guard let numbers = data.phones, let originalError = self?.originalError else {
                    self?.forwardGeneralError()
                    return
                }
                let loginError = LoginApiError<T>(error: originalError, interruption: .onRegisteredPhoneNumbers(numbers: numbers))
                
                self?.completion(.failure(loginError))
            case .failure(let error):
                
                self?.forwardError(error: error)
            }
        }
    }
    
    // MARK: - Gigya Email provider specific flow.
    
    internal func onTfaInitializedWithEmailProvider() {
        guard let gigyaAssertion = self.gigyaAssertion else {
            self.forwardInitialInterruption()
            return
        }
        self.businessDelegate?.sendApi(dataType: TFAEmailsModel.self, api: GigyaDefinitions.API.getEmailsTFA, params: ["gigyaAssertion": gigyaAssertion]) { [weak self] result in
            switch result {
            case .success(let data):
                guard let emails = data.emails, let originalError = self?.originalError else  {
                    self?.forwardGeneralError()
                    return
                }
            
                let loginError = LoginApiError<T>(error: originalError, interruption: .onRegisteredEmails(emails: emails))
                
                self?.completion(.failure(loginError))
            case .failure(let error):
                
                self?.forwardError(error: error)
            }
        }
    }
    
    internal func verifyRegisterdEmail(registeredEmail: TFAEmail) {
        let params = ["emailID": registeredEmail.id, "gigyaAssertion": self.gigyaAssertion, "lang": "eng"] as! [String: String]
        self.businessDelegate?.sendApi(dataType: TFAVerificationCodeModel.self, api: GigyaDefinitions.API.emailSendVerificationCodeTFA, params: params) { [weak self] result in
            switch result {
            case .success(let data):
                guard let phvToken = data.phvToken, let originalError = self?.originalError else {
                    self?.forwardGeneralError()
                    return
                }
                self?.phvToken = phvToken
                
                let loginError = LoginApiError<T>(error: originalError, interruption: .onEmailVerificationCodeSent)
                
                self?.completion(.failure(loginError))
            case .failure(let error):
                
                self?.forwardError(error: error)
            }
        }
    }
    
    // MARK: - Gigya Totp provider specific flow.
    
    internal func onTfaInitializedWithTotpProvider(mode: String, arguments: [String: Any]) {
        switch mode {
        case "register":
            
            self.getTotpQRCode()
        case "verify":
            guard let authorizationCode = arguments["authorizationCode"] as? String else {
                self.forwardGeneralError()
                return
            }
            
            self.verifyTotpAuthorizationCode(authorizationCode: authorizationCode)
        default:
            break
        }
    }
    
    internal func getTotpQRCode() {
        guard let gigyaAssertion = self.gigyaAssertion else {
            self.forwardGeneralError()
            return
        }
        self.businessDelegate?.sendApi(dataType: TFATotpRegisterModel.self, api: GigyaDefinitions.API.totpRegisterTFA, params: ["gigyaAssertion": gigyaAssertion]) { [weak self] result in
            switch result {
                
            case .success(let data):
                guard let sctToken = data.sctToken, let qrCode = data.qrCode, let originalError = self?.originalError else {
                    self?.forwardGeneralError()
                    return
                }
                
                self?.sctToken = sctToken
                let loginError = LoginApiError<T>(error: originalError, interruption: .onTotpQRCode(qrCode: qrCode))
                
                self?.completion(.failure(loginError))
            case .failure(let error):
                
                self?.forwardError(error: error)
            }
        }
    }
    
    internal func verifyTotpAuthorizationCode(authorizationCode: String) {
        guard let gigyaAssertion = self.gigyaAssertion, let sctToken = self.sctToken else {
            self.forwardInitialInterruption()
            return
        }
        
        let params = ["code": authorizationCode, "gigyaAssertion": gigyaAssertion, "sctToken": sctToken]
        verifyAuthorizationCode(api: GigyaDefinitions.API.totpVerifyTFA, params: params)
    }
    
}

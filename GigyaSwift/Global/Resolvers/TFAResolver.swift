//
//  TFAResolver.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 15/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public class TFAResolver<T: Codable> : BaseResolver {

    let completion: (GigyaLoginResult<T>) -> Void

    let originalError: NetworkError
    
    let regToken: String

    var gigyaAssertion: String?

    var phvToken: String?

    var sctToken: String?
    
    weak var businessDelegate: BusinessApiDelegate?

    public var inactiveProviders: [TFAProviderModel] = []
    
    public var activeProviders: [TFAProviderModel] = []

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
            guard let self = self else { return }

            switch result {
            case .success(let data):
                // Evaluate available providers.
                if let activeProviders = data.activeProviders {
                    if !activeProviders.isEmpty {
                        self.activeProviders = activeProviders
                    }
                }
                if let inactiveProviders = data.inactiveProviders {
                    if !inactiveProviders.isEmpty {
                        self.inactiveProviders = inactiveProviders
                    }
                }

                if self.activeProviders.count == 0 && self.inactiveProviders.count == 0 {
                    self.forwardGeneralError()
                    return
                }
                
                self.forwardInitialInterruption();
            case .failure(let error):
                self.forwardError(error: error)
            }
        }
    }
    
    func forwardInitialInterruption() {
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
    func forwardGeneralError() {
        let error = NetworkError.emptyResponse
        let loginError = LoginApiError<T>(error: error, interruption: nil)
        self.completion(.failure(loginError))
    }
    
    //MARK: - TFA common flow.
    
     func initTFA(tfaProvider: TFAProvider, mode: TFAMode, arguments: [String: String]) {
        let params = ["regToken": self.regToken, "provider" : tfaProvider.rawValue, "mode": mode.rawValue]
        self.businessDelegate?.sendApi(dataType: InitTFAModel.self, api: GigyaDefinitions.API.initTFA, params: params) { [weak self] result in
            switch result {
            case .success(let data):
                guard let gigyaAssertion = data.gigyaAssertion else {
                    self?.forwardGeneralError()
                    return
                }

                self?.gigyaAssertion = gigyaAssertion

                switch tfaProvider {
                case .phone, .liveLink:
                    self?.onTfaInitializedWithPhoneProvider(mode: mode, arguments: arguments)
                case .email:
                    self?.onTfaInitializedWithEmailProvider(gigyaAssertion: gigyaAssertion)
                case .totp:
                    self?.onTfaInitializedWithTotpProvider(gigyaAssertion: gigyaAssertion, mode: mode, arguments: arguments)
                }
            case .failure(let error):
                self?.forwardError(error: error)
            }
        }
    }
    
     func verifyAuthorizationCode(api: String, params: [String: String]) {
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
    
     func finalizeTfa(providerAssertion: String) {
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
    
     func onTfaInitializedWithPhoneProvider(mode: TFAMode, arguments: [String: Any]) {
        switch mode {
        case .register:
            let number = arguments["phoneNumber"] as! String
            let method = arguments["method"] as! String
            
            self.sendPhoneVerificationCode(number: number, method: method)
        case .verify:
            self.getRegisteredPhoneNumbers()
        }
    }
    
     func verifyPhoneAuthorizationCode(authorizationCode: String) {
        guard let gigyaAssertion = self.gigyaAssertion, let phvToken = self.phvToken else {
            self.forwardGeneralError()
            return
        }

        let params = ["gigyaAssertion": gigyaAssertion, "code": authorizationCode, "phvToken": phvToken]
        verifyAuthorizationCode(api: GigyaDefinitions.API.phoneCompleteVerificationTFA, params: params)
    }
    
     func sendPhoneVerificationCode(number: String = "", phoneId: String = "",  method: String) {
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
                guard let originalError = self?.originalError, let phvToken = data.phvToken else {
                    self?.forwardGeneralError()
                    return
                }

                self?.phvToken = phvToken

                let loginError = LoginApiError<T>(error: originalError, interruption: .onPhoneVerificationCodeSent)
                self?.completion(.failure(loginError))
            case .failure(let error):
                self?.forwardError(error: error)
            }
        }
    }
    
     func getRegisteredPhoneNumbers() {
        guard let gigyaAssertion = self.gigyaAssertion, !gigyaAssertion.isEmpty else {
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
    
    func onTfaInitializedWithEmailProvider(gigyaAssertion: String) {
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
    
     func verifyRegisterdEmail(registeredEmail: TFAEmail) {
        guard let gigyaAssertion = self.gigyaAssertion, let emailId = registeredEmail.id else {
            self.forwardGeneralError()
            return
        }

        let params = ["emailID": emailId, "gigyaAssertion": gigyaAssertion, "lang": "eng"]

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

     func verifyEmailAuthorizationCode(authorizationCode: String) {
        guard let gigyaAssertion = self.gigyaAssertion, let phvToken = self.phvToken else {
            self.forwardGeneralError()
            return
        }

        let params = ["gigyaAssertion": gigyaAssertion, "code": authorizationCode, "phvToken": phvToken]
        verifyAuthorizationCode(api: GigyaDefinitions.API.emailCompleteVerificationTFA, params: params)
    }
    
    // MARK: - Gigya Totp provider specific flow.
    
     func onTfaInitializedWithTotpProvider(gigyaAssertion: String, mode: TFAMode, arguments: [String: String]) {
        switch mode {
        case .register:
            self.getTotpQRCode(gigyaAssertion: gigyaAssertion)
        case .verify:
            guard let authorizationCode = arguments["authorizationCode"] else { return }
            
            self.verifyTotpAuthorizationCode(authorizationCode: authorizationCode)
        }
    }
    
    func getTotpQRCode(gigyaAssertion: String) {
        self.businessDelegate?.sendApi(dataType: TFATotpRegisterModel.self, api: GigyaDefinitions.API.totpRegisterTFA, params: ["gigyaAssertion": gigyaAssertion]) { [weak self] result in
            switch result {
                
            case .success(let data):
                guard let sctToken = data.sctToken, let qrCode = data.qrCode, let originalError = self?.originalError else {
                    self?.forwardGeneralError()
                    return
                }
                
                self?.sctToken = sctToken

                let qrImage = self?.makeImageFromQrData(data: qrCode)

                let loginError = LoginApiError<T>(error: originalError, interruption: .onTotpQRCode(qrCode: qrImage))
                self?.completion(.failure(loginError))
            case .failure(let error):
                self?.forwardError(error: error)
            }
        }
    }
    
     func verifyTotpAuthorizationCode(authorizationCode: String) {
        guard let gigyaAssertion = self.gigyaAssertion else {
            self.forwardGeneralError()
            return
        }
        
        var params = ["code": authorizationCode, "gigyaAssertion": gigyaAssertion]
        if let sctToken = self.sctToken {
            params["sctToken"] = sctToken
        }

        verifyAuthorizationCode(api: GigyaDefinitions.API.totpVerifyTFA, params: params)
    }

    private func makeImageFromQrData(data: String) -> UIImage? {
        // make qr image from string
        let split = data.components(separatedBy: ",")

        if split.count > 1, let dataDecoded = Data(base64Encoded: split[1], options: Data.Base64DecodingOptions.ignoreUnknownCharacters),
            let qrImage = UIImage(data: dataDecoded) {
            return qrImage
        }
        
        return nil
    }
}

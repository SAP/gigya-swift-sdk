////
////  TFAVerificationResolver.swift
////  GigyaSwift
////
////  Created by Tal Mirmelshtein on 15/05/2019.
////  Copyright © 2019 Gigya. All rights reserved.
////
//
//import Foundation
//import GigyaSwift
//
//public protocol TFAVerificationResolverProtocol {
//
//    var tfaProviders: [TFAProviderModel] { get set }
//
//    func startVerificationWithPhone()
//
//    func sendPhoneVerificationCode(registeredPhone: TFARegisteredPhone)
//
//    func startVerificationWithEmail()
//
//    func sendEmailVerificationCode(registeredEmail: TFAEmail)
//
//    func verificationWithTotp(authorizationCode: String)
//
//    func verifyCode(provider: TFAProvider, authenticationCode: String)
//}
//
//class TFAVerificationResolver<T: Codable> : TFAResolver<T>, TFAVerificationResolverProtocol {
//
//    lazy var tfaProviders: [TFAProviderModel] = {
//        return self.activeProviders
//    }()
//
//    override init(originalError: NetworkError, regToken: String, businessDelegate: BusinessApiDelegate, completion: @escaping (GigyaLoginResult<T>) -> Void) {
//        super.init(originalError: originalError, regToken: regToken, businessDelegate: businessDelegate, completion: completion)
//    }
//
//    override func forwardInitialInterruption() {
//        let loginError = LoginApiError<T>(error: self.originalError, interruption: .pendingTwoFactorVerification(resolver: self))
//        self.completion(.failure(loginError))
//    }
//
//    func verifyCode(provider: TFAProvider, authenticationCode: String) {
//        switch provider {
//        case .phone, .liveLink:
//            verifyPhoneAuthorizationCode(authorizationCode: authenticationCode)
//        case .email:
//            verifyEmailAuthorizationCode(authorizationCode: authenticationCode)
//        case .totp:
//            GigyaLogger.error(with: TFAVerificationResolver.self, message: "totp is not supported in verification")
//        }
//    }
//
//    func startVerificationWithPhone() {
//        initTFA(tfaProvider: .phone, mode: .verify, arguments: [:])
//    }
//
//    func sendPhoneVerificationCode(registeredPhone: TFARegisteredPhone) {
//        guard let phoneId = registeredPhone.id, let lastMethod = registeredPhone.lastMethod else {
//            forwardGeneralError()
//            return
//        }
//
//        sendPhoneVerificationCode(phoneId: phoneId, method: lastMethod)
//    }
//    
//    func startVerificationWithEmail() {
//        initTFA(tfaProvider: .email, mode: .verify, arguments: [:])
//    }
//
//    func sendEmailVerificationCode(registeredEmail: TFAEmail) {
//        verifyRegisterdEmail(registeredEmail: registeredEmail)
//    }
//
//    func verificationWithTotp(authorizationCode: String) {
//        initTFA(tfaProvider: .totp, mode: .verify, arguments: ["authorizationCode": authorizationCode])
//    }
//}

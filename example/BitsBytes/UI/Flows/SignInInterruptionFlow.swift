//
//  SignInInterruptionFlow.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 15/07/2024.
//

import Foundation
import Gigya
import GigyaTfa
import GigyaAuth

@Observable
class SignInInterruptionFlow: Identifiable {
    enum Interruptions {
        case none
        case penddingRegistration
        case conflitingAccount
        case pendingTwoFactorRegistration
        case pendingTwoFactorVerification
    }
    
    var currentFlow: Interruptions = .none {
        didSet {
            linkAccountResolver = nil
            penddingRegistrationResolver = nil
        }
    }
    
    weak var currentCordinator: Coordinator?
    
    var tfaFactoryResolver: TFAResolverFactory<AccountModel>?
    var linkAccountResolver: LinkAccountsResolver<AccountModel>?
    var penddingRegistrationResolver: PendingRegistrationResolver<AccountModel>?
    var otpResolver: OtpServiceVerifyProtocol?
    var pendingTwoFactorVerificationResolver: PendingRegistrationResolver<AccountModel>?
    
    var registerPhoneResolver: RegisterPhoneResolver<AccountModel>?
    var registeredPhonesResolver: RegisteredPhonesResolver<AccountModel>?
    var registeredEmailsResolver: RegisteredEmailsResolver<AccountModel>?
    
    var totpResolver: VerifyTotpResolverProtocol?

    var otpCurrentMode: OtpViewModel.Mode = .login
    var tfaSelectedProvider: TFAProvider = .phone
    var tfaAvailableProviders: [TFAProviderModel] = []
    var selectedPhone: TFARegisteredPhone?
    var selectedEmail: TFAEmail?

    var resultClosure: (GigyaLoginResult<AccountModel>) -> Void = { _ in }
    var resultOtpClosure: (GigyaOtpResult<AccountModel>) -> Void = { _ in }

    var successClousre: () -> Void = { }
    var errorClousre: (String) -> Void = { _ in }

    init() {
        resultOtpClosure = { [weak self] result in
            switch result {

            case .success(data: _):
                self?.successClousre()
            case .pendingOtpVerification(resolver: let resolver):
                self?.otpResolver = resolver
            case .failure(error: let error):
                self?.interuuptionHandle(error: error)
            }
        }
        
        resultClosure = { [weak self] result in
            switch result {
            case .success(data: _):
                self?.successClousre()
            case .failure(let error):
                self?.interuuptionHandle(error: error)
                
            }
        }
    }
    
    func interuuptionHandle(error: LoginApiError<AccountModel>) {
        switch error.error {
        case .gigyaError(data: let data):
            self.errorClousre(data.errorMessage ?? "")
        default:
            break
        }
        
        guard let interruption = error.interruption else { return }
        
        switch interruption {
        case .pendingRegistration(resolver: let resolver):
            self.currentCordinator?.routing.push(.penddingRegistration)

            self.currentFlow = .penddingRegistration
            self.penddingRegistrationResolver = resolver
        case .pendingVerification(regToken: let regToken):
            break
        case .pendingPasswordChange(regToken: let regToken):
            break
        case .conflitingAccount(resolver: let resolver):
            self.currentCordinator?.routing.push(.linkAccount)

            self.currentFlow = .conflitingAccount
            self.linkAccountResolver = resolver
        case .pendingTwoFactorRegistration(response: _, inactiveProviders: let inactiveProviders, factory: let factory):
            self.currentFlow = .pendingTwoFactorRegistration
            self.tfaAvailableProviders = inactiveProviders ?? []
            self.tfaFactoryResolver = factory
            self.otpCurrentMode = .tfaRegister
            registerPhoneResolver = factory.getResolver(for: RegisterPhoneResolver.self)
            self.currentCordinator?.routing.push(.tfaMethods)


        case .pendingTwoFactorVerification(response: _, activeProviders: let activeProviders, factory: let factory):
            self.currentFlow = .pendingTwoFactorVerification
            self.tfaAvailableProviders = activeProviders ?? []
            self.tfaFactoryResolver = factory
            registeredPhonesResolver = factory.getResolver(for: RegisteredPhonesResolver.self)
            
            self.otpCurrentMode = .tfaVerify
            
            self.currentCordinator?.routing.push(.tfaMethods)

        }
    }
    
}

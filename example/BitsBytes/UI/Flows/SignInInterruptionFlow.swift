//
//  SignInInterruptionFlow.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 15/07/2024.
//

import Foundation
import Gigya
import GigyaAuth

@Observable
class SignInInterruptionFlow: Identifiable {
    enum Interruptions {
        case none
        case penddingRegistration
        case conflitingAccount
    }
    
    var currentFlow: Interruptions = .none {
        didSet {
            linkAccountResolver = nil
            penddingRegistrationResolver = nil
        }
    }
    
    weak var currentCordinator: Coordinator?
    
    var linkAccountResolver: LinkAccountsResolver<AccountModel>?
    var penddingRegistrationResolver: PendingRegistrationResolver<AccountModel>?
    var otpResolver: OtpServiceVerifyProtocol?

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
        self.errorClousre(error.error.localizedDescription)
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
        case .pendingTwoFactorRegistration(response: let response, inactiveProviders: let inactiveProviders, factory: let factory):
            break
        case .pendingTwoFactorVerification(response: let response, activeProviders: let activeProviders, factory: let factory):
            break
        }
    }
    
}

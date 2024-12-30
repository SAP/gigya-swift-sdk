//
//  TfaMethodsViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 22/12/2024.
//


import Foundation
import Gigya
import GigyaTfa
import SwiftUI

@Observable
final class TfaMethodsViewModel: BaseViewModel {
    var error: String = ""
    var formIsSubmitState: Bool = false
    var state: State = .none
    var qrImage: UIImage?
    var code: String = ""

    enum State {
        case none
        case phone
        case totp
        case email
    }
    
    var registredPhones: [TFARegisteredPhone] = []
    
    var tempClosure: ()-> Void = { }

    let flowManager: SignInInterruptionFlow
    
    var totpResolver: RegisterTotpResolver<AccountModel>?
    var verifyTotpResolver: VerifyTotpResolverProtocol?

    init(gigya: GigyaService, flowManager: SignInInterruptionFlow) {
        self.flowManager = flowManager
        super.init(gigya: gigya)
    }
    
    func getPhones() {
        if flowManager.otpCurrentMode == .tfaRegister {
            self.flowManager.currentCordinator?.routing.push(.otpLogin)
        } else {
            flowManager.registeredPhonesResolver = flowManager.tfaFactoryResolver?.getResolver(for: RegisteredPhonesResolver.self)
            
            flowManager.registeredPhonesResolver?.getRegisteredPhones { [weak self] res in
                switch res {
                case .registeredPhones(phones: let phones):
                    self?.registredPhones = phones
                default:
                    break
                }
            }
        }
    }
    
    func getTotp() {
        if flowManager.otpCurrentMode == .tfaRegister {
            totpResolver = flowManager.tfaFactoryResolver?.getResolver(for: RegisterTotpResolver.self)
            
            totpResolver?.registerTotp { res in
                switch res {
                case .QRCodeAvilabe(image: let image, resolver: let resolver):
                    self.verifyTotpResolver = resolver
                    self.qrImage = image
                case .error(let error):
                    self.error = error.localizedDescription
                }
            }
        } else {
            verifyTotpResolver = flowManager.tfaFactoryResolver?.getResolver(for: VerifyTotpResolver.self)
        }
    }
    
    func verifyCode() {
        switch state {
        case .none:
            break
        case .phone:
            break
        case .totp:
            verifyTotpResolver?.verifyTOTPCode(verificationCode: code, rememberDevice: true) { res in
                switch res {
                case .resolved:
                    self.flowManager.currentCordinator?.routing.popToRoot()
                    self.flowManager.currentCordinator?.parent.isLoggedIn = true
                case .invalidCode:
                    self.error = "Invalid Code"
                case .failed(let error):
                    self.error = error.localizedDescription
                }
            }
        case .email:
            break
        }
    }

}

extension TFAProviderModel: @retroactive Equatable {}
extension TFAProviderModel: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
    
    public static func == (lhs: TFAProviderModel, rhs: TFAProviderModel) -> Bool {
        return lhs.name == rhs.name
    }
}

extension TFARegisteredPhone: @retroactive Equatable {}
extension TFARegisteredPhone: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
    
    public static func == (lhs: TFARegisteredPhone, rhs: TFARegisteredPhone) -> Bool {
        return lhs.obfuscated == rhs.obfuscated
    }
}


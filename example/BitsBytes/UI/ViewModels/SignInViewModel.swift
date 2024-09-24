//
//  SignInViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 07/03/2024.
//

import Foundation
import Gigya

final class SignInViewModel: BaseViewModel {
    @Published var error: String = ""
    @Published var biometricAvailable: Bool = false
        
    let flowManager: SignInInterruptionFlow

    init(gigya: GigyaService, flowManager: SignInInterruptionFlow) {
        self.flowManager = flowManager
        super.init(gigya: gigya)
        
        biometricAvailable = gigya.shared.biometric.isOptIn
        
    }
    
    func loginWithProvider(_ provider: GigyaSocialProviders, closure: @escaping ()-> Void) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first
                  as? UIWindowScene)?.windows.first?.rootViewController
              else { return }

        flowManager.successClousre = { [weak self] in
            self?.toggelLoader()
            closure()
        }
        
        toggelLoader()
        
        gigya?.shared.login(with: provider, viewController: presentingViewController, completion: flowManager.resultClosure)
    }
    
    func fidoLogin() async -> Bool {
        guard let presentingViewController = await (UIApplication.shared.connectedScenes.first
                  as? UIWindowScene)?.windows.first?.rootViewController
              else { return false}

        guard let result = await gigya?.shared.webAuthn.login(viewController: presentingViewController) else { return false}
  
        switch result {
        case .success(_):
            return true
        case .failure(let error):
            switch error.error {
            case .gigyaError(data: let data):
                self.error = data.errorMessage ?? ""

            default:
                break
            }
            return false
        }
        
    }
    
    func unlockSession(closure: @escaping ()-> Void) {
        gigya?.shared.biometric.unlockSession() { [weak self] res in
            switch res {
            case .success:
                closure()
            case .failure:
                self?.error = "unlock failed"
            }
        }
    }
}

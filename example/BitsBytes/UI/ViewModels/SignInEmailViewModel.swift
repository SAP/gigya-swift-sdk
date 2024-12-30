//
//  SignInEmailViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 06/03/2024.
//

import Foundation
import Gigya

final class SignInEmailViewModel: BaseViewModel {
    var currentCordinator: ProfileCoordinator?
    let flowManager: SignInInterruptionFlow

    @Published var formIsSubmitState: Bool = false
    @Published var email: String = ""
    @Published var pass: String = ""
    @Published var error: String = ""
    
    init(gigya: GigyaService, flowManager: SignInInterruptionFlow) {
        self.flowManager = flowManager
        super.init(gigya: gigya)
    }
    
    func submit(closure: @escaping ()-> Void) {
        formIsSubmitState = true
        toggelLoader()
        
        if (!email.isEmpty && !pass.isEmpty) {
            guard let gigya = gigya else {
                self.error = "Genral error"
                return
            }
            
            flowManager.successClousre = { [weak self] in
                self?.toggelLoader()
                closure()
            }
            
            flowManager.errorClousre = { [weak self] error in
                self?.error = error
                self?.toggelLoader()
            }
            
            gigya.shared.login(loginId: email, password: pass, completion: flowManager.resultClosure)
//            { [ weak self] result in
//                guard let self = self else { return }
//                
//                toggelLoader()
//                
//                switch result {
//                case .success(data: _):
//                    closure()
//                case .failure(let error):
//                    switch error.error {
//                    case .gigyaError(let data):
//                        self.error = data.errorMessage ?? "Genral Error"
//                    default:
//                        self.error = "Genral Error"
//                    }
//                }
//            }
        }
    }
    
    func showPass() {
        currentCordinator?.routing.push(.resetPassword)
    }
}

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
    @Published var captchaSwitch: Bool = false

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
            
            if captchaSwitch {
                captchaSwitch = false
                Task { [weak self] in
                    guard let self = self else { return }
                    
                    let token = try await self.gigya?.shared.getSaptchaToken()
                    let params: [String : Any] = ["captchaToken": token ?? "", "captchaType": "Saptcha"]
                    self.gigya?.shared.login(loginId: email, password: pass, params: params ,completion: self.flowManager.resultClosure)

                }
            } else {
                gigya.shared.login(loginId: email, password: pass, completion: flowManager.resultClosure)
            }

        }
    }
    
    func showPass() {
        currentCordinator?.routing.push(.resetPassword)
    }
}

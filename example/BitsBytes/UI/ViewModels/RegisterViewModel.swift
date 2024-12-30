//
//  RegisterViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 26/02/2024.
//

import Foundation
import Gigya

protocol InterruptionFlow {
    var flowManager: SignInInterruptionFlow { get set }
}

final class RegisterViewModel: BaseViewModel, InterruptionFlow {
    @Published var formIsSubmitState: Bool = false
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var pass: String = ""
    @Published var confirmPass: String = ""
    @Published var error: String = ""
    
    var flowManager: SignInInterruptionFlow

    init(gigya: GigyaService, flowManager: SignInInterruptionFlow) {
        self.flowManager = flowManager
        super.init(gigya: gigya)
    }
    
    func submit(closure: @escaping ()-> Void) {
        formIsSubmitState = true
        showLoder = true
        if !pass.isEmpty && !confirmPass.isEmpty && pass != confirmPass {
            self.error = "Password not match."
            self.toggelLoader()
            return
        } else if (!firstName.isEmpty && !email.isEmpty && !pass.isEmpty && !confirmPass.isEmpty) {
            guard let gigya = gigya else {
                self.error = "Genral error"
                self.toggelLoader()
                return
            }
            
            flowManager.successClousre = { [weak self] in
                self?.toggelLoader()
                closure()
            }
            
            flowManager.errorClousre = { [weak self] error in
                self?.error = error
            }
            
            gigya.shared.register(email: email, password: pass, params: ["profile": ["firstName": firstName, "lastName": lastName]], completion: flowManager.resultClosure)

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
//                    
//                }
//            }
        }
    }
}

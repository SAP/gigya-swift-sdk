//
//  OtpViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 10/06/2024.
//
import Gigya
import GigyaAuth

class OtpViewModel: BaseViewModel, InterruptionFlow {    
    
    @Published var error: String = ""
    @Published var phone: String = ""
    @Published var code: String = ""
    @Published var codeSent: Bool = false
    
    var flowManager: SignInInterruptionFlow
    
    enum Mode {
        case login
        case update
    }
    
    init(gigya: GigyaService, flowManager: SignInInterruptionFlow) {
        self.flowManager = flowManager
        super.init(gigya: gigya)
    }
    
    func sendCode(mode: Mode = .login, sucess: @escaping ()-> Void) {
        if phone.isEmpty {
            error = "Phone is empty"
            return
        }
                
        flowManager.successClousre = { [weak self] in
            self?.toggelLoader()
            sucess()
        }
        
        flowManager.errorClousre = { [weak self] error in
            self?.error = error
        }
        
        switch mode {
        case .login:
            GigyaAuth.shared.otp.login(phone: phone, completion: flowManager.resultOtpClosure)
        case .update:
            GigyaAuth.shared.otp.update(phone: phone, completion: flowManager.resultOtpClosure)
        }
        
        codeSent = true
        
//        { [weak self] (result: GigyaOtpResult<GigyaAccount>) in
//            switch result {
//            case .success(data: _):
//                sucess()
//            case .pendingOtpVerification(resolver: let resolver):
//                self?.codeSent = true
//                self?.otpResolver = resolver
//            case .failure(error: let error):
//                print(error.error)
//                self?.error = error.error.localizedDescription
//            }
//            
//            self?.toggelLoader()
//        }
    }
    
    func verifyCode() {
        guard let otpResolver = self.flowManager.otpResolver else {
            self.error = "Resolver not found"
            self.codeSent = false
            return
        }
        
        toggelLoader()
        
        otpResolver.verify(code: code)
    }
}

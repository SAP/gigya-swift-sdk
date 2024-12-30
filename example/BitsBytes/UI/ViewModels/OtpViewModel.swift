//
//  OtpViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 10/06/2024.
//
import Gigya
import GigyaTfa
import GigyaAuth

class OtpViewModel: BaseViewModel, InterruptionFlow {    
    
    @Published var title: String = ""
    @Published var error: String = ""
    @Published var phone: String = ""
    @Published var code: String = ""
    @Published var codeSent: Bool = false
    
    var flowManager: SignInInterruptionFlow
        
    var verifyCodeResolver: VerifyCodeResolverProtocol?
    
    enum Mode {
        case login
        case update
        case tfaRegister
        case tfaVerify
    }
    
    init(gigya: GigyaService, flowManager: SignInInterruptionFlow) {
        self.flowManager = flowManager
        super.init(gigya: gigya)
        
        self.phone = flowManager.selectedPhone?.obfuscated ?? ""
        
        switch flowManager.otpCurrentMode {
        case .login:
            title = "Sign In With Phone"
        case .update:
            title = "Add Your Phone"
        case .tfaRegister:
            title = "Register Tfa With Phone"
        case .tfaVerify:
            title = "Verify Tfa With Phone"
        }

    }
    
    func sendCode(sucess: @escaping ()-> Void) {
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
        
        switch flowManager.otpCurrentMode {
        case .login:
            GigyaAuth.shared.otp.login(phone: phone, completion: flowManager.resultOtpClosure)
        case .update:
            GigyaAuth.shared.otp.update(phone: phone, completion: flowManager.resultOtpClosure)
        case .tfaRegister:
            flowManager.registerPhoneResolver?.registerPhone(phone: phone) { [weak self] res in
                switch res {
                case .verificationCodeSent(resolver: let resolver):
                    self?.verifyCodeResolver = resolver
                case .error(let error):
                    self?.error = error.localizedDescription
                }
            }
        case .tfaVerify:
            switch flowManager.tfaSelectedProvider {
            case .phone:
                flowManager.registeredPhonesResolver?.sendVerificationCode(with: flowManager.selectedPhone!, method: .sms) { [weak self] result in
                    switch result {
                    case .registeredPhones(_):
                        break
                    case .verificationCodeSent(let resolver):
                        self?.verifyCodeResolver = resolver
                    case .error(_):
                        break

                    }
                }
            case .email:
                flowManager.registeredEmailsResolver?.sendEmailCode(with: flowManager.selectedEmail!) { [weak self] result in
                    switch result {
                    case .registeredEmails(_):
                        break
                    case .emailVerificationCodeSent(let resolver):
                        self?.verifyCodeResolver = resolver
                    case .error(_):
                        break
                        
                    }
                }
            default:
                break
            }

        }
        
        codeSent = true
    }

    func verifyCode() {
        switch flowManager.otpCurrentMode {
        case .login, .update:
            guard let otpResolver = self.flowManager.otpResolver else {
                self.error = "Resolver not found"
                self.codeSent = false
                return
            }
            
            toggelLoader()
            
            otpResolver.verify(code: code)
        case .tfaRegister, .tfaVerify:
            verifyCodeResolver?.verifyCode(provider: .phone, verificationCode: code, rememberDevice: true) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .resolved:
                    self.flowManager.successClousre()
                case .invalidCode:
                    self.error = "Invalid code"
                case .failed(let error):
                    self.error = error.localizedDescription
                }
            }
        }

    }
}

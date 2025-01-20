//
//  ChangePasswordViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 20/06/2024.
//

import Foundation

class ChangePasswordViewModel: BaseViewModel {
    @Published var error: String = ""
    
    @Published var currentPass: String = ""
    @Published var newPass: String = ""
    @Published var confirmPass: String = ""
    
    var flowManager: SignInInterruptionFlow
//
//    enum ChangePasswordType {
//        case changePassword
//        case interruptChangePassword
//    }
    
    init(gigya: GigyaService, flowManager: SignInInterruptionFlow) {
        self.flowManager = flowManager
        super.init(gigya: gigya)
    }
    
    func savePassword(sucess: @escaping ()-> Void) {
        if currentPass.isEmpty {
            error = "Current Password is empty"
            return
        } else if !newPass.isEmpty && !confirmPass.isEmpty && newPass != confirmPass {
            error = "Password not match"
            return
        }
        
        toggelLoader()
        var params = ["password": currentPass, "newPassword": newPass]
        if let regToken = flowManager.regToken {
            params["regToken"] = regToken
        }
                                
        gigya?.shared.send(api: "accounts.setAccountInfo", params: params) { [weak self] res in
          switch res {
            case .success(_):
              if let regToken = self?.flowManager.regToken {
                  self?.gigya?.shared.send(api: "accounts.finalizeRegistration", params: ["regToken": regToken]) { res in
                      sucess()
                  }
              } else {
                  sucess()
              }
            case .failure(let error):
                switch error {
                    
                case .gigyaError(data: let data):
                    let d = data.toDictionary()
                    
                    self?.error = d["errorDetails"] as? String ?? error.localizedDescription
                default:
                    self?.error = error.localizedDescription
                }

            }
            
            self?.toggelLoader()
        }
    }
    
}

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
    
    func savePassword(sucess: @escaping ()-> Void) {
        if currentPass.isEmpty {
            error = "Current Password is empty"
            return
        } else if !newPass.isEmpty && !confirmPass.isEmpty && newPass != confirmPass {
            error = "Password not match"
            return
        }
        
        toggelLoader()
        
        gigya?.shared.setAccount(with: ["password": currentPass, "newPassword": newPass]) { [weak self] res in
            switch res {
            case .success(_):
                sucess()
            case .failure(let error):
                switch error {
                    
                case .gigyaError(data: let data):
                    self?.error = data.errorMessage ?? error.localizedDescription
                default:
                    self?.error = error.localizedDescription
                }
            }
            
            self?.toggelLoader()
        }
    }
    
}

//
//  ResetPasswordViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 20/06/2024.
//

import Foundation

class ResetPasswordViewModel: BaseViewModel {
    @Published var error: String = ""
    @Published var email: String = ""
    @Published var resetSent: Bool = false

    func send() {
        toggelLoader()
        
        gigya?.shared.forgotPassword(loginId: email) { [weak self] res in
            switch res {
            case .success(data: _):
                self?.resetSent = true
            case .failure(let error):
                self?.error = error.localizedDescription
            }
            
            self?.toggelLoader()
        }
    }
}

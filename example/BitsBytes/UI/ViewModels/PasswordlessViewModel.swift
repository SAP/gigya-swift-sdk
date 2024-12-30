//
//  PasswordlessViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 29/05/2024.
//

import Foundation
import UIKit
import GigyaTfa

final class PasswordlessViewModel: BaseViewModel {
    @Published var fidoIsAvailable: Bool = false
    @Published var biometricAvailable: Bool = false
    @Published var error: String = ""
    @Published var msg: String = ""

    override init(gigya: GigyaService) {
        super.init(gigya: gigya)
        
        checkFidoState()
        
        biometricAvailable = gigya.shared.biometric.isOptIn
    }
    
    // MARK: - Fido

    func checkFidoState() {
        Task { [weak self ] in
            do {
                let account = try await self?.gigya?.shared.getAccount()
                let isAvailable = self?.gigya?.shared.webAuthn.passkeyForUser(uid: account?.UID)
                self?.fidoIsAvailable = isAvailable ?? false
            } catch (let error) {
                self?.error = error.localizedDescription
            }
        }
    }

    func useFido() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first
                  as? UIWindowScene)?.windows.first?.rootViewController
              else { return }

        toggelLoader()
        
        if fidoIsAvailable {
            Task {
                await gigya?.shared.webAuthn.revoke()
                self.checkFidoState()
                print("webAuthn.revoke")
                toggelLoader()
            }
        } else {
            Task {
                guard let result = await gigya?.shared.webAuthn.register(viewController: presentingViewController) else { return }
                print("webAuthn.register")

                switch result {
                case .success(data: _):
                    self.error = ""
                    self.checkFidoState()
                case .failure(let e):
                    switch e {
                    case .gigyaError(data: let data):
                        self.error = data.errorMessage ?? ""
                    default:
                        break
                    }
                }
                
                toggelLoader()
            }
        }
    }
    
    // MARK: - Biometrics
    
    func biometricAction() {
        toggelLoader()
        
        if !biometricAvailable {
            gigya?.shared.biometric.optIn() { [weak self] res in
                self?.biometricAvailable = self?.gigya?.shared.biometric.isOptIn ?? false
                self?.toggelLoader()
            }
        } else {
            gigya?.shared.biometric.optOut() { [weak self] res in
                self?.biometricAvailable = self?.gigya?.shared.biometric.isOptIn ?? false
                self?.toggelLoader()
            }
        }
    }
    
    func lockSession(closure: @escaping ()-> Void) {
        gigya?.shared.biometric.lockSession() { [weak self] res in
            switch res {
            case .success:
                closure()
            case .failure:
                self?.error = "Lock failed"
            }
        }
    }
    
    // MARK: - Push Tfa
    
    func pushTfaAction() {
        self.toggelLoader()
        
        GigyaTfa.shared.OptiInPushTfa { [weak self] res in
            switch res {
            case .success(let data):
                if self?.msg == "Push tfa optIn request sent" {
                    self?.msg = "Push tfa optIn successfully"
                    self?.toggelLoader()
                } else {
                    self?.msg = "Push tfa optIn request sent"
                }
            case .failure(_):
                self?.error = "Push tfa optIn in failed"
                self?.toggelLoader()
            }
        }
    }
}

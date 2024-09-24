//
//  LinkAccountViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 21/07/2024.
//

import Foundation
import Gigya

final class LinkAccountViewModel: BaseViewModel {
    @Published var email: String = ""
    @Published var pass: String = ""
    @Published var error: String = ""
    @Published var formIsSubmitState: Bool = false
    
    var tempClosure: ()-> Void = { }

    let flowManager: SignInInterruptionFlow

    init(gigya: GigyaService, flowManager: SignInInterruptionFlow) {
        self.flowManager = flowManager
        super.init(gigya: gigya)
        
        self.email = flowManager.linkAccountResolver?.conflictingAccount?.loginID ?? ""
    }
    
    func linkToSocial(provider: String, clousre: @escaping () -> Void) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first
                  as? UIWindowScene)?.windows.first?.rootViewController
              else { return }
        
        guard let provider = GigyaSocialProviders(rawValue: provider) else { return }
        
        flowManager.successClousre = { [weak self] in
            self?.toggelLoader()
            clousre()
        }
        
        toggelLoader()
        
        flowManager.linkAccountResolver?.linkToSocial(provider: provider, viewController: presentingViewController)
    }
    
    func linkToSite(clousre: @escaping () -> Void) {
        flowManager.successClousre = { [weak self] in
            self?.toggelLoader()
            clousre()
        }
        
        toggelLoader()
        
        flowManager.linkAccountResolver?.linkToSite(loginId: email, password: pass)
    }
}

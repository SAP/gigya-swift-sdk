//
//  LinkAccountsResolver.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 13/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

@objc protocol BaseResolver {
    @objc optional func start()
}

final public class LinkAccountsResolver<T: GigyaAccountProtocol>: BaseResolver {

    let originalError: NetworkError

    let regToken: String
    
    weak var businessDelegate: BusinessApiDelegate?

    let completion: (GigyaLoginResult<T>) -> Void
    
    public var conflictingAccount: ConflictingAccount?

    init(originalError: NetworkError, regToken: String, businessDelegate: BusinessApiDelegate, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        self.originalError = originalError
        self.regToken = regToken
        self.completion = completion
        self.businessDelegate = businessDelegate
    }

    internal func start() {
        // Request the conflicting account.
        getConflictingAccount()
    }
    
    private func getConflictingAccount() {
        let params = ["regToken": self.regToken]
        self.businessDelegate?.sendApi(dataType: ConflictingAccountHead.self, api: GigyaDefinitions.API.getConflictingAccount, params: params) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                GigyaLogger.log(with: self, message: "[getConflictingAccount]: success, accounts: \(data.conflictingAccount), originalError: \(self.originalError)")

                // Once we have the conflicting accounts we can pass on the first interruption through the completion block.
                self.conflictingAccount = data.conflictingAccount
                
                let loginError = LoginApiError<T>(error: self.originalError, interruption: .conflitingAccount(resolver: self))
                self.completion(.failure(loginError))
            case .failure(let error):
                GigyaLogger.log(with: self, message: "[getConflictingAccount]: failure, error: \(error)")

                let loginError = LoginApiError<T>(error: error, interruption: nil)

                self.completion(.failure(loginError))
            }
        }
    }
    
    public func linkToSite(loginId: String, password: String) {
        let params = ["loginMode": "link", "regToken": regToken]

        businessDelegate?.callLogin(dataType: T.self, loginId: loginId, password: password, params: params, completion: self.completion)

        GigyaLogger.log(with: self, message: "[linkToSite] - data: \(params)")
    }
    
    public func linkToSocial(provider: GigyaSocialProviders, viewController: UIViewController) {
        let params = ["loginMode": "link", "regToken": regToken]
        businessDelegate?.callSociallogin(provider: provider, viewController: viewController, params: params, dataType: T.self, completion: self.completion)

        GigyaLogger.log(with: self, message: "[linkToSocial] - data: \(params), provider: \(provider.rawValue)")

    }
}

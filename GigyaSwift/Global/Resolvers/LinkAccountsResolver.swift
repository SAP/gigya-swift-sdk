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
    
    let dataResponse: [String: Any]
    
    weak var businessDelegate: BusinessApiDelegate?

    let completion: (GigyaLoginResult<T>) -> Void
    
    public var conflictingAccount: ConflictingAccount?

    init(originalError: NetworkError, regToken: String, businessDelegate: BusinessApiDelegate, dataResponse: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        self.originalError = originalError
        self.regToken = regToken
        self.completion = completion
        self.businessDelegate = businessDelegate
        self.dataResponse = dataResponse
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
        if case .gigyaError(let error) = originalError, error.errorCode == Interruption.conflitingAccounts.rawValue {
            linkToSiteV2(loginId: loginId, password: password)
        } else {
            linkToSiteV1(loginId: loginId, password: password)
        }
    }
    
    public func linkToSocial(provider: GigyaSocialProviders, viewController: UIViewController) {
        if case .gigyaError(let error) = originalError, error.errorCode == Interruption.conflitingAccounts.rawValue {
            linkToSocialV2(provider: provider, viewController: viewController)
        } else {
            linkToSocialV1(provider: provider, viewController: viewController)
        }
    }
    
    private func linkToSiteV1(loginId: String, password: String) {
        let params = ["loginMode": "link", "regToken": regToken]

        businessDelegate?.callLogin(dataType: T.self, loginId: loginId, password: password, params: params, completion: self.completion)

        GigyaLogger.log(with: self, message: "[linkToSiteV1]")
    }
    
    private func linkToSocialV1(provider: GigyaSocialProviders, viewController: UIViewController) {
        let params = ["loginMode": "link", "regToken": regToken]
        businessDelegate?.callSociallogin(provider: provider, viewController: viewController, params: params, dataType: T.self, completion: self.completion)

        GigyaLogger.log(with: self, message: "[linkToSocialV1], provider: \(provider.rawValue)")
    }
    
    private func linkToSiteV2(loginId: String, password: String) {
        businessDelegate?.callLogin(dataType: T.self, loginId: loginId, password: password, params: [:]) { [weak self] result in
            switch result {
            case .success(data: _):
                self?.connectAccount()
            case .failure(let error):
                self?.completion(.failure(error))
            }
        }

        GigyaLogger.log(with: self, message: "[linkToSite] ")
    }
    
    private func linkToSocialV2(provider: GigyaSocialProviders, viewController: UIViewController) {
        businessDelegate?.callSociallogin(provider: provider, viewController: viewController, params: [:], dataType: T.self) { [weak self] result in
            switch result {
            case .success(data: _):
                self?.connectAccount()
            case .failure(let error):
                self?.completion(.failure(error))
            }
        }

        GigyaLogger.log(with: self, message: "[linkToSocial], provider: \(provider.rawValue)")
    }

    
    func connectAccount() {
        var params: [String: Any] = ["loginMode": "connect"]
    
        params["providerSessions"] = "{\"\(dataResponse["provider"] ?? "")\": {\"authToken\": \"\(dataResponse["access_token"] ?? "")\"}}"
        
        businessDelegate?.callNotifySocialLogin(dataType: T.self, params: params) { [weak self] res in
            switch res {
            case .success(data: let data):
                self?.completion(.success(data: data))
            case .failure(let error):
                self?.completion(.failure(.init(error: error)))
            }
        }
    }
}

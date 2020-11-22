//
//  PendingRegistrationResolver.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 18/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

final public class PendingRegistrationResolver<T: GigyaAccountProtocol>: BaseResolver {

    let originalError: NetworkError

    public let regToken: String

    weak var businessDelegate: BusinessApiDelegate?

    let completion: (GigyaLoginResult<T>) -> Void

    init(originalError: NetworkError, regToken: String, businessDelegate: BusinessApiDelegate, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        self.originalError = originalError
        self.regToken = regToken
        self.completion = completion
        self.businessDelegate = businessDelegate
    }

    internal func start() {
        let loginError = LoginApiError<T>(error: self.originalError, interruption: .pendingRegistration(resolver: self))
        self.completion(.failure(loginError))
    }

    public func setAccount(params: [String: Any]) {
        var newParams = params
        newParams["regToken"] = self.regToken

        businessDelegate?.sendApi(api: GigyaDefinitions.API.setAccountInfo, params: newParams, completion: { [weak self] (result) in
            switch result {
            case .success:
                guard let self = self else { return }

                self.businessDelegate?.callfinalizeRegistration(regToken: self.regToken, completion: self.completion)
            case .failure(let error):
                let loginError = LoginApiError<T>(error: error, interruption: nil)
                self?.completion(.failure(loginError))
            }
        })
    }

}

//
//  FacebookProvider.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FacebookProvider: Provider {

    weak var delegate: BusinessApiDelegate?

    var didFinish: () -> Void = { }

    let provider: ProviderWrapperProtocol

    public static func isAvailable() -> Bool {
        if NSClassFromString("FBSDKLoginManager") != nil {
            return true
        } else {
            return false
        }
    }

    init(provider: ProviderWrapperProtocol, delegate: BusinessApiDelegate) {
        self.provider = provider
        self.delegate = delegate
    }

    func login<T: Codable>(params: [String: Any], viewController: UIViewController? = nil, loginMode: String, completion: @escaping (GigyaApiResult<T>) -> Void) {
        provider.login(params: params, viewController: viewController) { [weak self] token, _, error in
            guard let self = self else { return }

            guard let token = token, error == nil else {
                self.loginFailed(error: error ?? "Id token no available", completion: completion)
                return
            }
            self.loginSuccess(providerSessions: self.getProviderSessions(token: token), loginMode: loginMode, params: params, completion: completion)

            self.logout()
        }
    }

    func logout() {
        provider.logout()
        didFinish()
    }

    func getProviderSessions(token: String) -> String {
        return "{\"\(GigyaSocielProviders.facebook.rawValue)\": {authToken: \"\(token)\"}}"
    }

    deinit {
        print("[FacebookProvider deinit]")
    }

}

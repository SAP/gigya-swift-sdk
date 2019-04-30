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

    let provider: ProviderWrapperProtocol

    public static func isAvailable() -> Bool {
        if NSClassFromString("FBSDKLoginKit") != nil {
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
        provider.login(params: params, viewController: viewController) { token, error in
            guard let token = token, error == nil else {
                self.loginFailed(error: error!.localizedDescription, completion: completion)
                return
            }
            self.loginSuccess(providerSessions: self.getProviderSessions(token: token), loginMode: loginMode, params: params, completion: completion)
        }
    }

    func logout() {
        provider.logout()
    }

    func getProviderSessions(token: String) -> String {
        return "{\"\(GigyaSocielProviders.facebook.rawValue)\": {authToken: \"\(token)\"}}"
    }

}

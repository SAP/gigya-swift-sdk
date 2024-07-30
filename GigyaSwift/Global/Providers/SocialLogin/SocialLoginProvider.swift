//
//  SocialLoginProvider.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 06/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

class SocialLoginProvider: Provider {

    weak var delegate: BusinessApiDelegate?

    var didFinish: () -> Void = { }

    let provider: ProviderWrapperProtocol

    let providerType: GigyaSocialProviders

    init(providerType: GigyaSocialProviders, provider: ProviderWrapperProtocol, delegate: BusinessApiDelegate) {
        self.provider = provider
        self.delegate = delegate
        self.providerType = providerType
    }

    func login<T: GigyaAccountProtocol>(type: T.Type, params: [String: Any], viewController: UIViewController? = nil, loginMode: String, completion: @escaping (GigyaApiResult<T>) -> Void) {
        provider.login(params: params, viewController: viewController) { [weak self] jsonData, error in
            guard let self = self else { return }
            
            guard let jsonData = jsonData, error == nil else {
                self.loginFailed(error: error ?? "Id token no available", completion: completion)
                return
            }

            self.loginSuccess(providerSessions: self.getProviderSessions(data: jsonData), loginMode: loginMode, params: params, completion: completion)

            self.logout()
        }
    }

    func logout() {
        if let logout = provider.logout {
            logout()
        }
        didFinish()
    }

    func getProviderSessions(data: [String: Any]) -> String {
        return "{\"\(providerType.rawValue)\": \(data.asJson)}"
    }

    deinit {
        print("[SocialLoginProvider deinit]")
    }
}

//
//  SocialLoginProvider.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 06/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class SocialLoginProvider: Provider {

    weak var delegate: BusinessApiDelegate?

    var didFinish: () -> Void = { }

    let provider: ProviderWrapperProtocol

    let providerType: GigyaSocielProviders

    init(providerType: GigyaSocielProviders, provider: ProviderWrapperProtocol, delegate: BusinessApiDelegate) {
        self.provider = provider
        self.delegate = delegate
        self.providerType = providerType
    }

    func login<T: Codable>(type: T.Type, params: [String: Any], viewController: UIViewController? = nil, loginMode: String, completion: @escaping (GigyaApiResult<T>) -> Void) {
        provider.login(params: params, viewController: viewController) { [weak self] jsonData, error in
            guard let self = self else { return }

            guard let token = jsonData?["accessToken"] as? String, !token.isEmpty, error == nil else {
                self.loginFailed(error: error ?? "Id token no available", completion: completion)
                return
            }

            let expiration = "\(jsonData?["tokenExpiration"] as? Int ?? 0)"

            self.loginSuccess(providerSessions: self.getProviderSessions(token: token, expiration: expiration), loginMode: loginMode, params: params, completion: completion)

            self.logout()
        }
    }

    func logout() {
        if let logout = provider.logout {
            logout()
        }
        didFinish()
    }

    func getProviderSessions(token: String, expiration: String?) -> String {
        switch providerType {
        case .facebook:
            return "{\"\(providerType.rawValue)\": {authToken: \"\(token)\", tokenExpiration: \"\(expiration ?? "")\"}}"
        case .line:
            return "{\"\(providerType.rawValue)\": {authToken: \"\(token)\"}}"
        case .google:
            return "{\"\(providerType.rawValue)\": {code: \"\(token)\"}}"
        case .wechat:
            return "{\"\(providerType.rawValue)\": {authToken: \"\(token)\", providerUID: \"\(provider.clientID ?? "")\"}}"
        default:
            break
        }

        return ""
    }

    deinit {
        print("[SocialLoginProvider deinit]")
    }
}

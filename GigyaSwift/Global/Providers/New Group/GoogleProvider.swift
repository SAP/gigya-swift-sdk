//
//  GoogleProvider.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 14/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GoogleSignIn

class GoogleProvider: Provider {

    weak var delegate: BusinessApiDelegate?

    var didFinish: () -> Void = { }

    let provider: ProviderWrapperProtocol

    init(provider: ProviderWrapperProtocol, delegate: BusinessApiDelegate) {
        self.provider = provider
        self.delegate = delegate
    }

    public static func isAvailable() -> Bool {
        if NSClassFromString("GIDSignIn") != nil {
            return true
        } else {
            return false
        }
    }

    func login<T: Codable>(params: [String: Any], viewController: UIViewController? = nil, loginMode: String, completion: @escaping (GigyaApiResult<T>) -> Void) {

        guard let clientID = provider.clientID, !clientID.isEmpty else {
            GigyaLogger.error(with: GoogleProvider.self, message: "Missing server client id. Check plist implementation")
        }

        provider.login(params: nil, viewController: nil) { [weak self] (serverAuthCode, _, error) in
            guard let self = self else { return }

            guard error == nil else {
                let errorDesc = error!.localizedDescription
                self.loginFailed(error: errorDesc, completion: completion)
                GigyaLogger.log(with: GoogleProvider.self, message: errorDesc)
                return
            }

            guard let authCode = serverAuthCode else {
                self.loginFailed(error: "Id token no available", completion: completion)
                return
            }

            self.loginSuccess(providerSessions: self.getProviderSessions(token: authCode),
                              loginMode: loginMode, params: params, completion: completion)

            self.logout()
        }
    }

    func logout() {
        provider.logout()
        didFinish()
    }

    func getProviderSessions(token: String) -> String {
        return "{\"\(GigyaSocielProviders.google.rawValue)\": {code: \"\(token)\"}}"
    }
}

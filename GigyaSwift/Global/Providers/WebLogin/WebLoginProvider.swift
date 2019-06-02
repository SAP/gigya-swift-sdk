//
//  WebViewProvider.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class WebLoginProvider: Provider {

    weak var delegate: BusinessApiDelegate?

    var didFinish: () -> Void = { }

    let provider: ProviderWrapperProtocol

    var completionHandler: (String?, String?, Error?) -> Void = { _, _, _  in }

    let sessionService: IOCSessionServiceProtocol

    init(sessionService: IOCSessionServiceProtocol, provider: ProviderWrapperProtocol, delegate: BusinessApiDelegate) {
        self.provider = provider
        self.delegate = delegate
        self.sessionService = sessionService
    }

    public static func isAvailable() -> Bool {
        return true
    }

    func login<T: Codable>(type: T.Type, params: [String: Any], viewController: UIViewController? = nil, loginMode: String, completion: @escaping (GigyaApiResult<T>) -> Void) {

        provider.login(params: params, viewController: viewController) { [weak self] jsonData, error in
            guard error == nil else {
                let errorDesc = error!
                self?.loginFailed(error: errorDesc, completion: completion)

                GigyaLogger.log(with: WebLoginProvider.self, message: errorDesc)
                return
            }

            guard
                let token = jsonData?["accessToken"] as? String,
                let secret = jsonData?["tokenSecret"] as? String,
                let sessionObject = GigyaSession(sessionToken: token, secret: secret),
                sessionObject.token.isEmpty == false else {
                    let errorDesc = "token no available"
                    self?.loginFailed(error: errorDesc, completion: completion)

                    GigyaLogger.log(with: WebLoginProvider.self, message: errorDesc)
                    return
            }

            self?.sessionService.setSession(sessionObject)

            self?.delegate?.callGetAccount(completion: { (result) in
                completion(result)
            })

            self?.logout()
        }
    }

    func logout() {
        didFinish()
    }

    func getProviderSessions(token: String, expiration: String?) -> String {
        return ""
    }

    deinit {
        print("[WebViewProvider deinit]")
    }
}

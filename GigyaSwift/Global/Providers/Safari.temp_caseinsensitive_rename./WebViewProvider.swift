//
//  WebViewProvider.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class WebViewProvider: Provider {

    weak var delegate: BusinessApiDelegate?

    let provider: ProviderWrapperProtocol

    var completionHandler: (String?, Error?) -> Void = { _, _  in }

    init(provider: ProviderWrapperProtocol, delegate: BusinessApiDelegate) {
        self.provider = provider
        self.delegate = delegate

        self.completionHandler = { token, error in
            self.logout()
        }
    }

    public static func isAvailable() -> Bool {
        return true
    }

    func login<T: Codable>(params: [String: Any], viewController: UIViewController? = nil, loginMode: String, completion: @escaping (GigyaApiResult<T>) -> Void) {

        provider.login(params: params, viewController: viewController, completion: completionHandler)
    }

    func logout() {

    }

    func getProviderSessions(token: String) -> String {
        return "{\"\(GigyaSocielProviders.web.rawValue)\": {code: \"\(token)\"}}"
    }

    deinit {
        print("[WebViewProvider deinit]")
    }
}

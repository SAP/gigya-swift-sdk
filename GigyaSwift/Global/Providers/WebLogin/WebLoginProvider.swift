//
//  WebViewProvider.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

final class WebLoginProvider: Provider {

    weak var delegate: BusinessApiDelegate?

    var didFinish: () -> Void = { }

    let provider: ProviderWrapperProtocol

    var completionHandler: (String?, String?, Error?) -> Void = { _, _, _  in }

    let sessionService: SessionServiceProtocol

    init(sessionService: SessionServiceProtocol, provider: ProviderWrapperProtocol, delegate: BusinessApiDelegate) {
        self.provider = provider
        self.delegate = delegate
        self.sessionService = sessionService
    }

    public static func isAvailable() -> Bool {
        return true
    }

    func login<T: GigyaAccountProtocol>(type: T.Type, params: [String: Any], viewController: UIViewController? = nil, loginMode: String, completion: @escaping (GigyaApiResult<T>) -> Void) {
        var newParams = params
        if newParams["loginMode"] as? String == nil {
            newParams["loginMode"] = loginMode
        }
        newParams["oauth_token"] = sessionService.session?.token
        newParams["secret"] = sessionService.session?.secret

        provider.login(params: newParams, viewController: viewController) { [weak self] jsonData, error in
            guard error == nil else {
                if error == GigyaDefinitions.Plugin.canceled {
                    let errorObject = NetworkError.providerError(data: error ?? "")

                    self?.loginGigyaFailed(error: errorObject, completion: completion)

                    GigyaLogger.log(with: WebLoginProvider.self, message: error ?? "")
                    return
                }
                let errorDesc = error!["error_description"]
                let getErrorCode = errorDesc?.split(separator: "+").first
                let errorCode = Int("\(getErrorCode ?? "-1")") ?? -1
                let regToken = error!["regToken"] ?? ""

                let data = ["regToken": regToken, "errorCode": errorCode] as [String : Any]

                let objData = try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)

                let errorObject = NetworkError.gigyaError(data: GigyaResponseModel(statusCode: .unknown, errorCode: errorCode, callId: "", errorMessage: error, sessionInfo: nil, requestData: objData))

                self?.loginGigyaFailed(error: errorObject, completion: completion)

                GigyaLogger.log(with: WebLoginProvider.self, message: errorObject.localizedDescription)
                return
            }

            if let isValidSession = self?.sessionService.isValidSession(), isValidSession {
                self?.delegate?.callGetAccount(completion: { (result) in
                    completion(result)
                })
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

            let sessionExpiration = jsonData?["sessionExpiration"] as? String

            let sessionInfo = SessionInfoModel(sessionToken: token, sessionSecret: secret, sessionExpiration: sessionExpiration)
            self?.sessionService.setSession(sessionInfo)

            self?.delegate?.callGetAccount(completion: { (result) in
                completion(result)
            })

            self?.logout()
        }
    }

    func logout() {
        didFinish()
    }

    func getProviderSessions(token: String, expiration: String?, code: String?, firstName: String?, lastName: String?) -> String {
        return ""
    }

    deinit {
        print("[WebViewProvider deinit]")
    }
}

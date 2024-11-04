//
//  WebViewWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit
import AuthenticationServices

@available(iOS 13.0, *)
final class SsoLoginWrapper: NSObject, ProviderWrapperProtocol {

    var clientID: String?

    var webViewController: ASWebAuthenticationLayer?

    private var networkProvider: NetworkProvider?

    private var config: GigyaConfig?

    private var persistenceService: PersistenceService?

    private var providerType: GigyaSocialProviders

    private var navigationController: UINavigationController?

    private var completionHandler: ((_ jsonData: [String: Any]?, _ error: String?) -> Void)? = nil
    
    private var pkceCode: PKCEHelper?

    static let callbackURLScheme = "gsapi"
    
    static let redirectUri = "\(callbackURLScheme)://\(Bundle.main.bundleIdentifier ?? "")/login/".lowercased()

    struct EndPoints {
        static let auth = "authorize"
        static let token = "token"
        static let loginPath = "/oidc/op/v1.0/"
        static var fidmUrl = "https://fidm."
    }

    required override init() {
        self.providerType = .web(provider: "")
    }

    init(config: GigyaConfig, persistenceService: PersistenceService, providerType: GigyaSocialProviders, networkProvider: NetworkProvider) {
        self.providerType = providerType
        self.config = config
        self.persistenceService = persistenceService
        self.networkProvider = networkProvider

        super.init()

        self.pkceCode = try? PKCEHelper()
    }

    func login(params: [String: Any]?, viewController: UIViewController?,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {
        
        loadProvider(params: params ?? [:])

        completionHandler = completion

        webViewController?.closure = { [weak self] json, error in
            guard let self = self else { return }

            if let error = error {
                completion(json, error)
            } else {
                self.getSessionFrom(code: json?["code"] as? String ?? "")
            }
        }

        webViewController?.show()
    }

    func loadProvider(params: [String: Any]) {
        let urlString = getUrl(path: EndPoints.auth)

        var requestParams: [String: Any] = [:]
        requestParams["redirect_uri"] = SsoLoginWrapper.redirectUri
        requestParams["response_type"] = "code"
        requestParams["client_id"] = config?.apiKey ?? ""
        requestParams["scope"] = "device_sso"
        requestParams["code_challenge"] = pkceCode?.challenge ?? ""
        requestParams["code_challenge_method"] = "S256"
        
        let paramsMapAsJson = params.mapValues {
            if let p = $0 as? [String: Any] {
                return p.asJson
            }
            return String(describing: $0)
        }
        
        requestParams.merge(paramsMapAsJson) { _, new  in new }
        requestParams.removeValue(forKey: "secret")

        let dataURL = URL(string: "\(urlString)?\(requestParams.asURI)")!

        webViewController = ASWebAuthenticationLayer(url: dataURL)
    }

    private func getUrl(path: String = "") -> String {
        return "\(config!.cnameEnable ? "https://": EndPoints.fidmUrl)\(self.config?.apiDomain ?? "")\(EndPoints.loginPath)\(self.config?.apiKey ?? "")/\(path)"
    }

    private func getSessionFrom(code: String) {
        var params: [String: Any] = [:]
        params["redirect_uri"] = SsoLoginWrapper.redirectUri
        params["client_id"] = self.config?.apiKey ?? ""
        params["code_verifier"] = self.pkceCode?.verifier ?? ""
        params["grant_type"] = "authorization_code"
        params["code"] = code

        let urlString = getUrl()

        networkProvider?.unsignRequest(url: urlString, model: ApiRequestModel(method: EndPoints.token, params: params), completion: { [weak self] data, error in

            guard let self = self else { return }

            if let res = self.responseHandler(data: data, error: error) {
                self.createSession(response: res)
            }
        })
    }

    private func createSession(response: [String: Any]) {
        guard
            let sessionToken = response["access_token"] as? String,
            let sessionSecret = response["device_secret"] as? String
        else {
            self.completionHandler?(nil, "general error")
            return
        }

        let json: [String : Any] = ["status": "ok", "accessToken": sessionToken, "tokenSecret": sessionSecret, "sessionExpiration": String(response["expires_in"] as? Int ?? 0)]

        self.completionHandler?(json, nil)
    }

    private func responseHandler(data: NSData?, error: Error?) -> [String: Any]? {
        do {
            guard let data = data,
                  let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String: Any]
            else {
                self.completionHandler?(nil, "general error")
                return nil
            }

            if let _ = json["access_token"] as? String {
                return json
            } else if let error = json["error_uri"] as? String {
                self.completionHandler?(nil, error)
            } else if let error = json["error_description"] as? String {
                self.completionHandler?(nil, error)
            }

        } catch let error {
            self.completionHandler?(nil, error.localizedDescription)
        }

        return nil
    }
}

@available(iOS 13.0, *)
class ASWebAuthenticationLayer: NSObject, ASWebAuthenticationPresentationContextProviding
{
    var closure: ([String: Any]?, String?) -> Void = { _, _ in}

    let url: URL
    
    private var session: ASWebAuthenticationSession?

    init(url: URL) {
        self.url = url
    }

    func show() {
        let handler: ASWebAuthenticationSession.CompletionHandler = { [self] u, error in
            if let error = error as? NSError {
                if error.code == 1 {
                    closure(nil, GigyaDefinitions.Plugin.canceled)
                    return
                }
                closure(nil, error.localizedDescription)
                return
            }
            
            if let u = u, u.absoluteString.contains("error") {
                closure(nil, u["error_uri"])
                return
            }

            if let u = u, u.absoluteString.contains(SsoLoginWrapper.redirectUri) {
                GigyaLogger.log(with: self, message: "Log redirect url: \(u)")
                if let code = u.valueOf("code") {
                    GigyaLogger.log(with: self, message: "code: \(code)")
                    closure(["code": code], nil)

                } else {
                    closure(nil, u.absoluteString)
                }
            }
        }
        
        if #available(iOS 17.4, *) {
            session = ASWebAuthenticationSession.init(url: url, callback: .customScheme(SsoLoginWrapper.callbackURLScheme), completionHandler: handler)
        } else {
            session = ASWebAuthenticationSession(url: url, callbackURLScheme: SsoLoginWrapper.callbackURLScheme, completionHandler: handler)
        }

        session?.presentationContextProvider = self

        session?.start()
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { window in
            return window.isKeyWindow
        } ?? UIApplication.shared.windows.first!
    }
}

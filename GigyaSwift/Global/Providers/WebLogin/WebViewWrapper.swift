//
//  WebViewWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit

final class WebLoginWrapper: NSObject, ProviderWrapperProtocol {

    var clientID: String?

    var webViewController: GigyaWebViewController?

    private var networkAdapter: NetworkAdapterProtocol?

    private var config: GigyaConfig?

    private var persistenceService: PersistenceService?

    private var providerType: GigyaSocialProviders

    private var navigationController: UINavigationController?

    private var completionHandler: ((_ jsonData: [String: Any]?, _ error: String?) -> Void)? = nil

    required override init() {
        self.providerType = .web(provider: "")
    }

    init(config: GigyaConfig, persistenceService: PersistenceService, providerType: GigyaSocialProviders, networkAdapter: NetworkAdapterProtocol) {
        self.providerType = providerType
        self.config = config
        self.persistenceService = persistenceService
        self.webViewController = GigyaWebViewController()

        self.networkAdapter = networkAdapter

        super.init()

        webViewConfig()
    }

    func webViewConfig() {

        webViewController?.setDelegate(delegate: self)

        webViewController?.userDidCancel = { [weak self] in
            self?.completionHandler?(nil, GigyaDefinitions.Plugin.canceled)
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }

    }

    func login(params: [String: Any]?, viewController: UIViewController?,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {

        locadProvider(params: params)

        completionHandler = completion
        
        navigationController = UINavigationController(rootViewController: webViewController!)

        if let navigationController = navigationController {
            viewController?.show(navigationController, sender: nil)
        }
    }

    func locadProvider(params: [String: Any]?) {
        var loginMode = "standard"
        if let mode = params?["loginMode"] as? String {
            loginMode = mode
        }

        var loginPath = "socialize.login"
        if loginMode == "connect" {
            loginPath = "socialize.addConnection"
        }

        let urlString = "https://socialize.\(config?.apiDomain ?? "")/\(loginPath)"

        var serverParams: [String: Any] = [:]
        serverParams["redirect_uri"] = "gsapi://login_result"
        serverParams["response_type"] = "token"
        serverParams["client_id"] = config?.apiKey ?? ""
        serverParams["gmid"] = persistenceService?.gmid ?? ""
        serverParams["ucid"] = persistenceService?.ucid ?? ""
        serverParams["x_secret_type"] = "oauth1"
        serverParams["x_s€dk"] = InternalConfig.General.version
        serverParams["x_provider"] = providerType.rawValue
        serverParams["oauth_token"] = params?["oauth_token"] ?? ""

        if let params = params {
            for param in params {
                if param.key.contains("x_") {
                    serverParams[param.key] = param.value
                } else {
                    serverParams["x_\(param.key)"] = param.value
                }
            }
        }

        var bodyData: [String : Any] = [:]

        do {
            bodyData = try SignatureUtils.prepareSignature(config: config!, persistenceService: persistenceService!, session: GigyaSession(sessionToken: params?["oauth_token"] as? String ?? "", secret: params?["secret"] as? String ?? ""), path: loginPath, params: serverParams)

        } catch let error {
            GigyaLogger.log(with: self, message: "error to make signature in web social login - \(error.localizedDescription)")
        }

        let urlAllowed = NSCharacterSet(charactersIn: GigyaDefinitions.charactersAllowed).inverted

        let bodyDataParmas = bodyData.mapValues { value -> String in
            return "\(value)"
        }

        let bodyString: String = bodyDataParmas.sorted(by: <).reduce("") { "\($0)\($1.0)=\($1.1.addingPercentEncoding(withAllowedCharacters: urlAllowed) ?? "")&" }

        let dataURL = URL(string: urlString)!   

        var request: URLRequest = URLRequest(url: dataURL)

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.httpBody = bodyString.dropLast().data(using: String.Encoding.utf8)

        if #available(iOS 11, *) {
            webViewController?.webView.load(request)
        } else {

            let html = """
            <html>
                <head>
                    <script>
                        function post() {
                        //how to call： post('URL', {"key": "value"});
                            var method = "post";
                            var paramsx = "\(bodyString)";
                            var params = new URLSearchParams(paramsx);

                            var form = document.createElement("form");
                            form.setAttribute("method", method);
                            form.setAttribute("action", "\(urlString)");
                            for (const [key, value] of params) {
                                var hiddenField = document.createElement("input");
                                hiddenField.setAttribute("type", "hidden");
                                hiddenField.setAttribute("name", key);
                                hiddenField.setAttribute("value", value.replace(" ","+"));
                                form.appendChild(hiddenField);
                            }

                            document.body.appendChild(form);

                            form.submit();
                        }
                    </script>
                </head>
                <body onload='post();'>
                </body>
            </html>

            """
            webViewController?.webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)

        }
    }
}

extension WebLoginWrapper: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other || navigationAction.navigationType == .formSubmitted {
            if let url = navigationAction.request.url {
                GigyaLogger.log(with: providerType.rawValue, message: "Log redirect url: \(url)")
                if
                    let status = url["status"],
                    status == "ok",
                    let accessToken = url["access_token"],
                    let tokenSecret = url["x_access_token_secret"] {
                    let sessionExpiration = url["expires_in"] ?? "0"

                    let json = ["status": status, "accessToken": accessToken, "tokenSecret": tokenSecret, "sessionExpiration": sessionExpiration]


                    completionHandler?(json, nil)

                    // dismiss viewController
                    navigationController?.dismiss(animated: true, completion: nil)
                } else if
                    let status = url["status"],
                    status == "ok",
                    let idToken = url["id_token"] {

                    let json = ["status": status, "idToken": idToken]

                    completionHandler?(json, nil)

                    // dismiss viewController
                    navigationController?.dismiss(animated: true, completion: nil)

                } else if let error = url["error_description"], !error.isEmpty {

                    completionHandler?(nil, url.absoluteString)

                    navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        decisionHandler(.allow)
    }
}

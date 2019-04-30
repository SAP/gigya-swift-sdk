//
//  WebViewWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit

class WebViewWrapper: NSObject, ProviderWrapperProtocol {
    var clientID: String?

    var webViewController: WebViewController

    var config: GigyaConfig

    let providerType: GigyaSocielProviders

    var navigationController: UINavigationController?

    private var completionHandler: (String?, String?, Error?) -> Void = { _, _, _  in }

    init(config: GigyaConfig, providerType: GigyaSocielProviders) {
        self.providerType = providerType
        self.config = config
        self.webViewController = WebViewController()

        super.init()

        let urlString = getUrl()

        guard let url = URL(string: urlString) else {
            return
        }

        webViewController.setDelegate(delegate: self)

        webViewController.loadUrl(url: url)

    }

    func login(params: [String: Any]?, viewController: UIViewController?, completion: @escaping (String?, String?, Error?) -> Void) {
        completionHandler = completion
        
        navigationController = UINavigationController(rootViewController: webViewController)

        if let navigationController = navigationController {
            viewController?.show(navigationController, sender: nil)
        }
    }

    func logout() {

    }

    func getUrl() -> String {
        var url = "https://socialize.\(config.apiDomain ?? "")/socialize.login?"
        url.append("redirect_uri=gsapi://login_result&")
        url.append("response_type=token&")
        url.append("client_id=\(config.apiKey ?? "")&")
        url.append("gmid=\(config.gmid ?? "")&")
        url.append("ucid=\(config.ucid ?? "")&")
        url.append("x_secret_type=oauth1&")
        url.append("x_endPoint=socialize.login&")
        url.append("x_sdk=\(InternalConfig.General.version)&")
        url.append("x_provider=\(providerType.rawValue)")

        return url
    }

    deinit {
        print("[WebViewWra deinit]")
    }
}

extension WebViewWrapper: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            if let url = navigationAction.request.url {
                print("Url: \(url)")
                if let accessToken = url["access_token"], let tokenSecret = url["x_access_token_secret"] {
                    print(accessToken)
                    print(tokenSecret)
                    completionHandler(accessToken, tokenSecret, nil)
                    // make login
                    navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        decisionHandler(.allow)
    }
}

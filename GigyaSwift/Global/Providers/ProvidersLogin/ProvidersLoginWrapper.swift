//
//  ProvidersLoginViewController.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 11/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import WebKit

class ProvidersLoginWrapper: NSObject {

    var webViewController: GigyaWebViewController?

    private var config: GigyaConfig?

    private var persistenceService: PersistenceService?

    private let providers: [GigyaSocialProviders]

    private var navigationController: UINavigationController?

    private var completionHandler: ((_ jsonData: [String: Any]?, _ error: String?) -> Void)? = nil

    init(config: GigyaConfig, persistenceService: PersistenceService, providers: [GigyaSocialProviders]) {
        self.providers = providers
        self.config = config
        self.persistenceService = persistenceService
        self.webViewController = GigyaWebViewController()

        super.init()

        webViewConfig()

    }

    func webViewConfig() {
        guard let url = getUrl(params: [:]) else { return }

        webViewController?.loadUrl(url: url)

        webViewController?.setDelegate(delegate: self)

        webViewController?.userDidCancel = { [weak self] in
            self?.completionHandler?(nil, GigyaDefinitions.Plugin.canceled)
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }

        webViewController?.title = "Sign In"

    }

    func show(params: [String: Any]?, viewController: UIViewController?,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {


        completionHandler = completion

        navigationController = UINavigationController(rootViewController: webViewController!)

        if let navigationController = navigationController {
            viewController?.show(navigationController, sender: nil)
        }
    }

    func getUrl(params: [String: Any]?) -> URL? {
        let lang = params?["lang"] ?? InternalConfig.General.defaultLang
        let disabledProviders = params?["disabledProviders"] ?? ""

        let providersString = providers.filter { $0.isSupported() }.map { "\($0)" }.joined(separator: ",")
        var urlString = "https://socialize.\(config?.apiDomain ?? "")/gs/mobile/LoginUI.aspx?"
        urlString.append("redirect_uri=gsapi://result&")
        urlString.append("requestType=login&")
        urlString.append("iosVersion=\(UIDevice.current.systemVersion)&")
        urlString.append("apikey=\(config?.apiKey ?? "")&")
        urlString.append("gmid=\(persistenceService?.gmid ?? "")&")
        urlString.append("ucid=\(persistenceService?.ucid ?? "")&")
        urlString.append("sdk=\(InternalConfig.General.version)&")
        urlString.append("enabledProviders=\(providersString)&")
        urlString.append("disabledProviders=\(disabledProviders)&")
        urlString.append("lang=\(lang)&")

        guard let url = URL(string: urlString) else {
            GigyaLogger.log(with: WebLoginWrapper.self, message: "Cna't make URL")
            return nil
        }

        return url
    }

    func dismiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension ProvidersLoginWrapper: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            if let url = navigationAction.request.url {
                 GigyaLogger.log(with: self, message: "Log redirect url: \(url)")

                if let provider = url["provider"] {
                    completionHandler?(["provider": provider], nil)
                } else {
                    completionHandler?(nil, "Failed to login")
                }
            }
        }
        
        decisionHandler(.allow)
    }

}

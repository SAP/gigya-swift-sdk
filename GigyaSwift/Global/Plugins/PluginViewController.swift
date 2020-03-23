//
//  PluginViewController.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 01/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit

final class PluginViewController<T: GigyaAccountProtocol>: GigyaWebViewController, WKNavigationDelegate {

    let contentController = WKUserContentController()

    var webBridge: GigyaWebBridge<T>

    init(webBridge: GigyaWebBridge<T>, pluginEvent: @escaping (GigyaPluginEvent<T>) -> Void) {
        self.webBridge = webBridge

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController

        super.init(configuration: webViewConfiguration)

        self.webBridge.attachTo(webView: self.webView, viewController: self, pluginEvent: pluginEvent)

        self.webBridge.viewController = self
        self.webView.navigationDelegate = self

        userDidCancel = {
            pluginEvent(.onHide(event: ["event": "screenSet cancelled"]))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
         if navigationAction.navigationType == WKNavigationType.linkActivated {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
         }
         decisionHandler(.allow)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

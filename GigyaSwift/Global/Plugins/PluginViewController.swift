//
//  PluginViewController.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 01/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit

final class PluginViewController<T: GigyaAccountProtocol>: GigyaWebViewController, WKNavigationDelegate, WKUIDelegate {

    let contentController = WKUserContentController()

    var webBridge: GigyaWebBridge<T>

    let pluginEvent: (GigyaPluginEvent<T>) -> Void

    init(webBridge: GigyaWebBridge<T>, pluginEvent: @escaping (GigyaPluginEvent<T>) -> Void) {
        self.webBridge = webBridge
        self.pluginEvent = pluginEvent

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        webViewConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webViewConfiguration.preferences.javaScriptEnabled = true

        super.init(configuration: webViewConfiguration)

        self.webBridge.attachTo(webView: self.webView, viewController: self, pluginEvent: pluginEvent)

        self.webBridge.viewController = self
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self

        userDidCancel = {
            pluginEvent(.onCanceled)
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

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // network error
        pluginEvent(.error(event: ["error": error.localizedDescription]))
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

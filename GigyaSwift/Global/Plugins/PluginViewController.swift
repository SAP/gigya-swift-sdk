//
//  PluginViewController.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 01/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit

class PluginViewController<T: GigyaAccountProtocol>: WebViewController {

    let contentController = WKUserContentController()

    var webBridge: GigyaWebBridge<T>
    
    init(webBridge: GigyaWebBridge<T>, pluginEvent: @escaping (GigyaPluginEvent<T>) -> Void) {
        self.webBridge = webBridge

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        
        super.init(configuration: webViewConfiguration)

        self.webBridge.attachTo(webView: self.webView, viewController: self, pluginEvent: pluginEvent)

        self.webBridge.viewController = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

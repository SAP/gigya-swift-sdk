//
//  PluginViewController.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 01/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSDK
import WebKit

class PluginViewController: WebViewController, WKScriptMessageHandler {
    
    let config: GigyaConfig
    
    let bridge: IOCWebBridgeProtocol
    
    var plugin: String
    
    var params: [String:Any]

    let contentController = WKUserContentController()

    init(config: GigyaConfig, bridge: IOCWebBridgeProtocol, plugin: String, params: [String: Any]) {
        self.config = config
        self.bridge = bridge
        self.plugin = plugin
        self.params = params
        

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        
        let supportedFeatures = ["is_session_valid", "send_request", "send_oauth_request", "get_ids", "on_plugin_event", "on_custom_event", "register_for_namespace_events", "on_js_exception", "on_js_log", "clear_session"]
        
        let json = "['is_session_valid','send_request','send_oauth_request','get_ids','on_plugin_event','on_custom_event','register_for_namespace_events','on_js_exception']"

//        let script = "window.__gigAPIAdapterSettings = { getAdapterName: function() { return 'mobile'; }, getAPIKey: function() { return '\(config.apiKey!)'; }, getFeatures: function() { return '\(json)';}}"
        let script = """
    window.__gigAPIAdapterSettings = { getAdapterName: function() { return 'mobile'; },getAPIKey: function() { return '3_Rnp81vcr2T8l9ikyU7zXDeT2BqhFoaEMK-X5_CGssphkkfNITZIU7FafZqJpJl5H'; },getFeatures: function() { return '["is_session_valid","send_request","send_oauth_request","get_ids","on_plugin_event","on_custom_event","register_for_namespace_events","on_js_exception","on_js_log","clear_session"]'; },getSettings: function() { return '{"logLevel":"error"}';},sendToMobile: function(action,method,queryStringParams) {
            var postObject = {
                action: action,
                method: method,
                params: queryStringParams
            };
            window.webkit.messageHandlers.gsapi.postMessage(postObject);return true}
        }
"""

        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        
        super.init(configuration: webViewConfiguration)

        contentController.add(self, name: "gsapi")


    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    func load(html: String) {
        webView.loadHTMLString(html, baseURL: URL(string: "http://www.gigya.com"))
    }
    
    // MARK: - WKScriptMessageHandler protocol
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //bridge.onJSMessage(message: message)
        if let json = message.body as? [String:Any] {
            let action = json["action"] as! String
            if action == "get_ids" {
                let params = json["params"] as! String
                let callbackID = params["callbackID"]
                let ids = [
                    "ucid": "\(UserDefaults.standard.object(forKey: InternalConfig.Storage.UCID) ?? "")",
                    "gcid": "\(UserDefaults.standard.object(forKey: InternalConfig.Storage.GMID) ?? "")"
                ]
                let script = "gigya._.apiAdapters.mobile.mobileCallbacks['\(callbackID!)'](\(ids.toJsonString));"
                webView.evaluateJavaScript(script)
                print(script)
            }

            if action == "is_session_valid" {
                let params = json["params"] as! String
                let callbackID = params["callbackID"]
                let script = "gigya._.apiAdapters.mobile.mobileCallbacks['\(callbackID!)'](\(Gigya.isSessionValid()));"
                webView.evaluateJavaScript(script)
            }
        }
    }
    
    
    deinit {
        print("deinit webrige")
    }
    
}

extension Array {
    func toJSON() -> String {
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: self, options: [])
        return String(data: jsonData ?? Data(), encoding: .utf8)!
    }
}

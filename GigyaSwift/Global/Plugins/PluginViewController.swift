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

class PluginViewController<T: GigyaAccountProtocol>: WebViewController, WKScriptMessageHandler {
    
    let config: GigyaConfig
    
    weak var delegate: PluginEventDelegate?
    
    let sessionService: IOCSessionServiceProtocol
    
    let businessApiService: IOCBusinessApiServiceProtocol
    
    let contentController = WKUserContentController()
    
    let JSEventHandler = "gsapi"
    
    init(config: GigyaConfig, sessionService: IOCSessionServiceProtocol, businessApiService: IOCBusinessApiServiceProtocol, delegate: PluginEventDelegate?) {
        self.config = config
        self.sessionService = sessionService
        self.businessApiService = businessApiService
        self.delegate = delegate
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        
        super.init(configuration: webViewConfiguration)
        
        // Add JS Interface.
        let JSInterface = getJSInterface()
        let userScript = WKUserScript(source: JSInterface, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        GigyaLogger.log(with: self, message: "JS Interface:\n\(JSInterface)")
        
        contentController.add(self, name: JSEventHandler)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(html: String) {
        webView.loadHTMLString(html, baseURL: URL(string: "http://www.gigya.com"))
    }
    
    // MARK: - JS Interface
    
    func getJSInterface() -> String {
        let JSFeatures =  ["is_session_valid","send_request","send_oauth_request","get_ids","on_plugin_event","on_custom_event","register_for_namespace_events","on_js_exception","on_js_log","clear_session"];
        
        let JSInterface =  """
        window.__gigAPIAdapterSettings = {
        getAdapterName: function() { return 'mobile'; },
        getAPIKey: function() { return '\(config.apiKey!)'; },
        getFeatures: function() { return '\(JSFeatures)';},
        getSettings: function() { return '{"logLevel":"error"}';},
        sendToMobile: function(action,method,queryStringParams) {
        var postObject = {
        action: action,
        method: method,
        params: queryStringParams
        };
        window.webkit.messageHandlers.\(JSEventHandler).postMessage(postObject); return true; }
        }
        """
        return JSInterface
    }
    
    // MARK: - WKScriptMessageHandler protocol

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Parse message.
        guard let messageMap = message.body as? [String:Any] else {
            GigyaLogger.log(with: self, message:"WKScriptMessage: error - failed to parse message")
            return
        }
        // Parse action & parameters.
        GigyaLogger.log(with: self, message: "WKScriptMessage:\n\(messageMap)")
        guard let data = messageMap["params"] as? String, let action = messageMap["action"] as? String else {
            GigyaLogger.log(with: self, message:"WKScriptMessage: error - failed to parse action & paramters")
            return
        }
        // Parse JS callback id.
        guard let callbackId = data["callbackID"] else {
            GigyaLogger.log(with: self, message:"WKScriptMessage: error - failed to parse callbackID")
            return
        }
        
        // Invoke action.
        switch action {
        case "get_ids":
            let ids = ["ucid": config.ucid ?? "","gcid": config.gmid ?? ""]
            invokeCallback(id: callbackId, and: ids.asJson)
        case "is_session_valid":
            let isValid = sessionService.isValidSession()
            invokeCallback(id: callbackId, and: "\(isValid)")
        case "send_request":
            guard let apiMethod = messageMap["method"] as? String, let params = data["params"] else {
                GigyaLogger.log(with: self, message: "WKScriptMessage: error - failed to parse api method & request parameters")
                return
            }
            switch apiMethod {
            case "accounts.register", "accounts.login":
                sendLoginRequest(id: callbackId, apiMethod: apiMethod, params: params.asDictionary())
                break;
            case "socialize.addConnection, accounts.addConnection":
                sendAddConnectionRequest(id: callbackId, params: params.asDictionary())
                break
            case "socialize.removeConnection":
                sendRemoveConnectionRequest(id: callbackId, params: params.asDictionary())
                break;
            default:
                sendRequest(id: callbackId, apiMethod: apiMethod, params: params.asDictionary())
            }
        case "send_oauth_request":
            guard let apiMethod = messageMap["method"] as? String, let params = data["params"] else {
                GigyaLogger.log(with: self, message: "WKScriptMessage: error - failed to parse api method & request parameters")
                return
            }
            sendOauthRequest(id: callbackId, apiMethod: apiMethod, params: params.asDictionary())
        case "on_plugin_event":
            break
        default:
            break
        }
    }
    
    func invokeCallback(id: String, and result: String) {
        let JS = "gigya._.apiAdapters.mobile.mobileCallbacks['\(id)'](\(result));"
        GigyaLogger.log(with: self, message: "invokeCallback:\n\(JS)")
        webView.evaluateJavaScript(JS)
    }
    
    func sendRequest(id: String, apiMethod: String, params: [String:String]) {
        GigyaLogger.log(with: self, message: "sendRequest: with apiMethod = \(apiMethod)")
        businessApiService.send(api: apiMethod, params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                GigyaLogger.log(with: self, message: "sendRequest: success")
                // Mapping AnyCodable values. Otherwise we will crash in the JSON dictionary conversion.
                let mapped: [String: Any] = data.mapValues { value in return value.value }
                self.invokeCallback(id: id, and: mapped.asJson)
            case .failure(let error):
                GigyaLogger.log(with: self, message: "sendRequest: error:\n\(error.localizedDescription)")
                switch error {
                case .gigyaError(let data):
                    self.delegate?.onError(error: data)
                    self.invokeCallback(id: id, and: data.asJson())
                default:
                    break
                }
            }
        }
    }
    
    func sendLoginRequest(id: String, apiMethod: String, params: [String:String]) {
        GigyaLogger.log(with: self, message: "sendLoginRequest: with params:\n\(params)")
        businessApiService.send(dataType: T.self, api: apiMethod, params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                GigyaLogger.log(with: self, message: "sendOauthRequest success")
                self.delegate?.onEvent(event: .onLogin(account: data))
                self.dismissPluginController()
            case .failure(let error):
                GigyaLogger.log(with: self, message: "sendRequest: error:\n\(error.localizedDescription)")
                switch error {
                case .gigyaError(let data):
                    self.delegate?.onError(error: data)
                    self.invokeCallback(id: id, and: data.asJson())
                default:
                    break
                }
            }
        }
    }
    
    func sendAddConnectionRequest(id: String, params: [String:String]) {
        GigyaLogger.log(with: self, message: "sendAddConnectionRequest: with params:\n\(params)")
    }
    
    func sendRemoveConnectionRequest(id: String, params: [String:String]) {
        GigyaLogger.log(with: self, message: "sendRemoveConnectionRequest: with params:\n\(params)")
    }
    
    func sendOauthRequest(id: String, apiMethod: String, params: [String:String]) {
        GigyaLogger.log(with: self, message: "sendOauthRequest: with apiMethod = \(apiMethod)")
        guard let providerName = params["provider"] else { return }
        if let provider = GigyaSocielProviders.byName(name: providerName) {
            businessApiService.login(provider: provider, viewController: self, params: params, dataType: T.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    GigyaLogger.log(with: self, message: "sendOauthRequest success")
                    self.delegate?.onEvent(event: .onLogin(account: data))
                    self.dismissPluginController()
                case .failure(let error):
                    GigyaLogger.log(with: self, message: "sendOauthRequest: error:\n\(error.localizedDescription)")
                    switch error {
                    case .gigyaError(let data):
                        self.delegate?.onError(error: data)
                        self.invokeCallback(id: id, and: data.asJson())
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func dismissPluginController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

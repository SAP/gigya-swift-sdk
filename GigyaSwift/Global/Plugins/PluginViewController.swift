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
    
    let sessionService: IOCSessionServiceProtocol
    
    let businessApiService: IOCBusinessApiServiceProtocol
    
    let contentController = WKUserContentController()
    
    let JSEventHandler = "gsapi"
    let baseURL = "http://www.gigya.com"
    
    var completion: (PluginEvent<T>) -> Void?
    
    init(config: GigyaConfig, sessionService: IOCSessionServiceProtocol, businessApiService: IOCBusinessApiServiceProtocol,
         completion: @escaping (PluginEvent<T>) -> Void?) {
        self.config = config
        self.sessionService = sessionService
        self.businessApiService = businessApiService
        self.completion = completion
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        
        super.init(configuration: webViewConfiguration)
        
        // Add JS Interface.
        let JSInterface = getJSInterface()
        let userScript = WKUserScript(source: JSInterface, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        contentController.add(self, name: JSEventHandler)
        
        GigyaLogger.log(with: self, message: "JS Interface:\n\(JSInterface)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(html: String) {
        webView.loadHTMLString(html, baseURL: URL(string: baseURL))
    }
    
    // MARK: - JS Interface
    
    /**
     Get the JS interface declaretion needed for injection.
     Without correctly declaring the JS interface the web JS plugin would not be able to bridge communicate with the application.
     */
    private func getJSInterface() -> String {
        // List of available JS communication features - not all are used.
        let JSFeatures =  ["is_session_valid","send_request","send_oauth_request","get_ids","on_plugin_event","on_custom_event",
                           "register_for_namespace_events","on_js_exception","on_js_log","clear_session"];
        
        // Declare the JS interface.
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
            invokeCallback(callbackId: callbackId, and: ids.asJson)
        case "is_session_valid":
            let isValid = sessionService.isValidSession()
            invokeCallback(callbackId: callbackId, and: "\(isValid)")
        case "send_request":
            guard let apiMethod = messageMap["method"] as? String, let params = data["params"] else {
                GigyaLogger.log(with: self, message: "WKScriptMessage: error - failed to parse api method & request parameters")
                return
            }
            // Some API methods require different handling due to mobile relevant endpoint updates.
            mapSendRequest(callbackId: callbackId, apiMethod: apiMethod, params: params.asDictionary())
        case "send_oauth_request":
            guard let apiMethod = messageMap["method"] as? String, let params = data["params"] else {
                GigyaLogger.log(with: self, message: "WKScriptMessage: error - failed to parse api method & request parameters")
                return
            }
            sendOauthRequest(callbackId: callbackId, apiMethod: apiMethod, params: params.asDictionary())
        case "on_plugin_event":
            guard let params = data["params"]?.asDictionary() else { return }
            if let sourceContainerId = params["sourceContainerID"] {
                if (sourceContainerId == "pluginContainer") {
                    onPluginEvent(type: T.self, params: params)
                }
            }
        default:
            break
        }
    }
    
    /**
     JS invocation of given result.
     */
    private func invokeCallback(callbackId: String, and result: String) {
        let JS = "gigya._.apiAdapters.mobile.mobileCallbacks['\(callbackId)'](\(result));"
        GigyaLogger.log(with: self, message: "invokeCallback:\n\(JS)")
        webView.evaluateJavaScript(JS)
    }
    
    /**
     Delegate received error to client.
     JS invocation of given error result.
     */
    private func invokeError(callbackId: String, error: NetworkError) {
        switch error {
        case .gigyaError(let data):
            self.completion(.error(event: data.toDictionary()))
            self.invokeCallback(callbackId: callbackId, and: data.asJson())
        default:
            break
        }
    }
    
    /**
     Mapping received api method to the relevant "sendRequest" logic.
     */
    private func mapSendRequest(callbackId: String, apiMethod: String, params: [String: String]) {
        switch apiMethod {
        case "socialize.socialLogin", "accounts.socialLogin":
            sendOauthRequest(callbackId: callbackId, apiMethod: apiMethod, params: params)
            break
        case "accounts.register", "accounts.login":
            sendLoginRequest(callbackId: callbackId, apiMethod: apiMethod, params: params)
            break;
        case "socialize.addConnection, accounts.addConnection":
            sendAddConnectionRequest(callbackId: callbackId, params: params)
        case "socialize.removeConnection":
            sendRemoveConnectionRequest(callbackId: callbackId, params: params)
        default:
            sendRequest(callbackId: callbackId, apiMethod: apiMethod, params: params)
        }
    }
    
    /**
     Delegate received plugin events to client.
     */
    private func onPluginEvent<T>(type: T.Type, params: [String: String]) {
        if let eventName = params["eventName"] {
            switch eventName {
            case "beforeScreenLoad":
                completion(.onBeforeScreenLoad(event: params))
            case "afterScreenLoad":
                completion(.onAfterScreenLoad(event: params))
            case "beforeSubmit":
                completion(.onBeforeSubmit(event: params))
            case "submit":
                completion(.onSubmit(event: params))
            case "afterSubmit":
                completion(.onAfterSubmit(event: params))
            case "hide":
                completion(.onHide(event: params))
                dismissPluginController()
            case "error":
                completion(.error(event: params))
            default:
                break
            }
        }
    }
    
    /**
     Generic send request method.
     */
    private func sendRequest(callbackId: String, apiMethod: String, params: [String: String]) {
        GigyaLogger.log(with: self, message: "sendRequest: with apiMethod = \(apiMethod)")
        businessApiService.send(api: apiMethod, params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                GigyaLogger.log(with: self, message: "sendRequest: success")
                // Mapping AnyCodable values. Otherwise we will crash in the JSON dictionary conversion.
                let mapped: [String: Any] = data.mapValues { value in return value.value }
                self.invokeCallback(callbackId: callbackId, and: mapped.asJson)
            case .failure(let error):
                GigyaLogger.log(with: self, message: "sendRequest: error:\n\(error.localizedDescription)")
                self.invokeError(callbackId: callbackId, error: error)
            }
        }
    }
    
    
    /**
     Send a login/register request. Response data is typed to the current provided account.
     */
    private func sendLoginRequest(callbackId: String, apiMethod: String, params: [String: String]) {
        GigyaLogger.log(with: self, message: "sendLoginRequest: with params:\n\(params)")
        businessApiService.send(dataType: T.self, api: apiMethod, params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                GigyaLogger.log(with: self, message: "sendOauthRequest success")
                self.completion(.onLogin(account: data))
                self.dismissPluginController()
            case .failure(let error):
                GigyaLogger.log(with: self, message: "sendLoginRequest: error:\n\(error.localizedDescription)")
                self.invokeError(callbackId: callbackId, error: error)
            }
        }
    }
    
    /**
     Send a request to add a social connection to the current active account/session.
     */
    private func sendAddConnectionRequest(callbackId: String, params: [String: String]) {
        GigyaLogger.log(with: self, message: "sendAddConnectionRequest: with params:\n\(params)")
        guard let providerToAdd = params["provider"] else { return }
        if let provider = GigyaSocielProviders.byName(name: providerToAdd) {
            businessApiService.addConnection(provider: provider, viewController: self, params: params, dataType: T.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success( _):
                    GigyaLogger.log(with: self, message: "sendOauthRequest success")
                    self.completion(.onConnectionAdded)
                    self.dismissPluginController()
                case .failure(let error):
                    GigyaLogger.log(with: self, message: "sendOauthRequest: error:\n\(error.localizedDescription)")
                    self.invokeError(callbackId: callbackId, error: error)
                }
            }
        }
    }
    
    /**
     Send a request to remove a social connection from the current active account/session.
     */
    private func sendRemoveConnectionRequest(callbackId: String, params: [String: String]) {
        GigyaLogger.log(with: self, message: "sendRemoveConnectionRequest: with params:\n\(params)")
        if let provider = params["provider"] {
            businessApiService.removeConnection(providerName: provider) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    GigyaLogger.log(with: self, message: "sendRemoveConnectionRequest success")
                    let mapped: [String: Any] = data.mapValues { value in return value.value }
                    self.invokeCallback(callbackId: callbackId, and: mapped.asJson)
                    self.completion(.onConnectionRemoved)
                    self.dismissPluginController()
                case .failure(let error):
                    GigyaLogger.log(with: self, message: "sendRemoveConnectionRequest: error:\n\(error.localizedDescription)")
                    self.invokeError(callbackId: callbackId, error: error)
                }
            }
        }
    }
    
    /**
     Send a social login request that is dependent on a specific social provider login process.
     */
    private func sendOauthRequest(callbackId: String, apiMethod: String, params: [String: String]) {
        GigyaLogger.log(with: self, message: "sendOauthRequest: with apiMethod = \(apiMethod)")
        guard let providerName = params["provider"] else { return }
        if let provider = GigyaSocielProviders.byName(name: providerName) {
            businessApiService.login(provider: provider, viewController: self, params: params, dataType: T.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    GigyaLogger.log(with: self, message: "sendOauthRequest success")
                    self.completion(.onLogin(account: data))
                    self.dismissPluginController()
                case .failure(let data):
                    GigyaLogger.log(with: self, message: "sendOauthRequest: error:\n\(data.error.localizedDescription)")
                    self.invokeError(callbackId: callbackId, error: data.error)
                }
            }
        }
    }
    
  
    
    /**
     Dismiss the encapsulating view controller after a task has been completed.
     */
    private func dismissPluginController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

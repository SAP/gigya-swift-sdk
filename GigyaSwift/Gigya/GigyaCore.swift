//
//  GigyaSW.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 10/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSDK

public class GigyaCore<T: GigyaAccountProtocol>: GigyaInstanceProtocol {

    internal var container: IOCContainer?

    // Default api domain
    private var defaultApiDomain: String {
        return InternalConfig.Storage.defaultApiDomain
    }

    // Initialize Dependencies
    private var config: GigyaConfig {
        return (container?.resolve(GigyaConfig.self))!
    }

    private var gigyaApi: IOCGigyaWrapperProtocol {
        return (container?.resolve(IOCGigyaWrapperProtocol.self))!
    }

    private var businessApiService: IOCBusinessApiServiceProtocol {
        return (container?.resolve(IOCBusinessApiServiceProtocol.self))!
    }

    private var sessionService: IOCSessionServiceProtocol {
        return (container?.resolve(IOCSessionServiceProtocol.self))!
    }
    
    // MARK: - Initialize
    internal init(container: IOCContainer, plistConfig: PlistConfig) {
        self.container = container

        // Init Gigya Objc when thr host add params in plist
        if let apiKey = plistConfig.apiKey, !apiKey.isEmpty {
            initWithApi(apiKey: apiKey, apiDomain: plistConfig.apiDomain)
        }
    }

    /**
     Initialize the SDK.

     - Parameter apiKey:     Client API-KEY
     - Parameter apiDomain:  Request Domain.
     */

    public func initWithApi(apiKey: String, apiDomain: String? = nil, application: UIApplication? = nil, launchOptions: [AnyHashable: Any]? = nil) {
        guard !apiKey.isEmpty else {
            GigyaLogger.error(with: GigyaSwift.self, message: "please make sure you call 'initWithApi' or add apiKey to plist file")
        }
//        config.isInitSdk = true
        config.apiDomain = apiDomain ?? self.defaultApiDomain
        config.apiKey = apiKey

        gigyaApi.initGigyaSDK(apiKey: apiKey, apiDomain: apiDomain, application: application, launchOptions: launchOptions)
    }

    // MARK: - Anonymous API

    /**
     Send request to Gigya servers.

     - Parameter api:          Method identifier.
     - Parameter params:       Additional parameters.
     - Parameter completion:   Response GigyaApiResult<GigyaDictionary>.
     */

    public func send(api: String, params: [String: String] = [:], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        businessApiService.send(api: api, params: params, completion: completion)
    }

    /**
     Send request with generic type.

     - Parameter api:         Method identifier.
     - Parameter params:      Additional parameters.
     - Parameter completion:  Response GigyaApiResult<T>.
     */

    public func send<B: Codable>(dataType: B.Type, api: String, params: [String: String] = [:], completion: @escaping (GigyaApiResult<B>) -> Void ) {
        businessApiService.send(dataType: dataType, api: api, params: params, completion: completion)
    }

    // TODO: test api with self request
//    internal func sendTest1(api: String, params: [String: String] = [:]) {
//        Gigya.getSessionWithCompletionHandler { (session) in
//            let networkService = NetworkProvider(url: self.defaultApiDomain)
//
//            networkService.dataRequest(gsession: session!,path: api, body: params, responseType: GigyaDictionary.self, completion: { (res) in
//
//            })
//        }
//    }

    // MARK: - Session

    /**
     * Check if a valid session.
     */
    public func isLoggedIn() -> Bool {
        return sessionService.isValidSession()
    }

    /**
     * Logout of Gigya services.
     */
    public func logout(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        sessionService.clear()
        businessApiService.logout(completion: completion)
    }

    // MARK: - Business Api׳s

    /**
     Login api

     - Parameter identity:      user identity.
     - Parameter pass:          user password.
     - Parameter completion:    Response GigyaApiResult.
     */
    public func login(loginId: String, password: String, completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.login(dataType: T.self, loginId: loginId, password: password, completion: completion)
    }

    /**
     Login with 3rd provider

     - Parameter provider:          user identity.
     - Parameter params:            user password.
     - Parameter viewController:    your ViewController should be open login
     - Parameter completion:        Response GigyaApiResult.
     */
    public func login(with provider: GigyaSocielProviders, viewController: UIViewController,
                      params: [String: Any] = [:], completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.login(provider: provider, viewController: viewController, params: params, dataType: T.self) { (res) in
            completion(res)
        }
    }

    /**
     Register api

     - Parameter email:         user identity.
     - Parameter pass:          user password.
     - Parameter completion:    Response GigyaApiResult.
     */
    public func register(params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.register(params: params, dataType: T.self, completion: completion)
    }

    /**
     Get account api

     - Parameter type:         Host data schema.
     - Parameter completion:   Response GigyaApiResult<T>.
     */
    public func getAccount(completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.getAccount(dataType: T.self, completion: completion)
    }

    /**
     * Set account info.

     - Parameter account:      Host data obj.
     - Parameter completion:   Response GigyaApiResult<T>.
    */
    public func setAccount(account: T, completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.setAccount(obj: account, completion: completion)
    }

    // MARK: - Native login

    /**
     Present social login selection list.

     - Parameter providers: List of selected social providers (GigyaSocielProviders).
     - Parameter params:    Request parameters.
     - Parameter completion:  Login response.
     */

    public func socialLoginWith(providers: [GigyaSocielProviders], params: [String: Any], completion: (GigyaApiResult<Any>) -> Void) {

    }
    
    /**
     Add a social connection to current account.
     
     - Parameter providers: selected social provider (GigyaSocielProviders).
     - Parameter viewController: Shown view controller.
     - Parameter params:    Request parameters.
     - Parameter completion:  Login response.
     */
    
    public func addConnection(provider: GigyaSocielProviders, viewController: UIViewController, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.addConnection(provider: provider, viewController: viewController, params: params, dataType: T.self, completion: completion)
    }
    
    /**
     Remove a social connection from current account.
     
     - Parameter providers: selected social provider name.
     - Parameter completion:  Login response.
     */
    
    public func removeConnection(provider: String, completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        businessApiService.removeConnection(providerName: provider, completion: completion)
    }

    // MARK: - Plugins

    /**
    Show ScreenSet

    - Parameter name:        ScreenSet name.
    - Parameter viewController: Shown view controller.
    - Parameter params:      General ScreenSet parameters.
    - Parameter completion:  Plugin completion.
    */
    
    public func showScreenSet(name: String, viewController: UIViewController, params: [String: Any] = [:], completion: @escaping (PluginEvent<T>) -> Void) {
        let wrapper = PluginViewWrapper(config: config, sessionService: sessionService, businessApiService: businessApiService, plugin: "accounts.screenSet", params: params, completion: completion)
        wrapper.presentPluginController(viewController: viewController, dataType: T.self, screenSet: name)
    }

    /**
     * Show comments (ScreenSet)
     *
     * :param params:   Comments ScreenSet parameters.
     * :param completion:  Plugin completion.
     */

    public func showComments() {

    }
}

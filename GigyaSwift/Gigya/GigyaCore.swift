//
//  GigyaSW.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 10/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaInfra

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

    private var interruptionResolver: IOCInterruptionResolverFactory {
        return (container?.resolve(IOCInterruptionResolverFactory.self))!
    }

    // MARK: - Initialize
    internal init(container: IOCContainer, plistConfig: PlistConfig?) {
        self.container = container

        // Init Gigya Objc when thr host add params in plist
        if let apiKey = plistConfig?.apiKey, !apiKey.isEmpty {
            initFor(apiKey: apiKey, apiDomain: plistConfig?.apiDomain)
        }
    }

    /**
     Initialize the SDK.

     - Parameter apiKey:     Client API-KEY
     - Parameter apiDomain:  Request Domain.
     */

    public func initFor(apiKey: String, apiDomain: String? = nil) {
        guard !apiKey.isEmpty else {
            GigyaLogger.error(with: Gigya.self, message: "please make sure you call 'initWithApi' or add apiKey to plist file")
        }

        config.apiDomain = apiDomain ?? self.defaultApiDomain
        config.apiKey = apiKey
        
        gigyaApi.initGigyaSDK(apiKey: apiKey, apiDomain: apiDomain, application: nil, launchOptions: nil)
    }

    // MARK: - Anonymous API

    /**
     Send request to Gigya servers.

     - Parameter api:          Method identifier.
     - Parameter params:       Additional parameters.
     - Parameter completion:   Response GigyaApiResult<GigyaDictionary>.
     */

    public func send(api: String, params: [String: Any] = [:], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        businessApiService.send(api: api, params: params, completion: completion)
    }

    /**
     Send request with generic type.

     - Parameter api:         Method identifier.
     - Parameter params:      Additional parameters.
     - Parameter completion:  Response GigyaApiResult<T>.
     */

    public func send<B: Codable>(dataType: B.Type, api: String, params: [String: Any] = [:], completion: @escaping (GigyaApiResult<B>) -> Void ) {
        businessApiService.send(dataType: dataType, api: api, params: params, completion: completion)
    }

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
    public func login(loginId: String, password: String, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        businessApiService.login(dataType: T.self, loginId: loginId, password: password, params: [:], completion: completion)
    }

    /**
     Login with 3rd provider

     - Parameter provider:          user identity.
     - Parameter params:            user password.
     - Parameter viewController:    your ViewController should be open login
     - Parameter completion:        Response GigyaApiResult.
     */
    public func login(with provider: GigyaSocialProviders, viewController: UIViewController,
                      params: [String: Any] = [:], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        businessApiService.login(provider: provider, viewController: viewController, params: params, dataType: T.self) { (res) in
            completion(res)
        }
    }

    /**
     Register api

     - Parameter email:         user identity.
     - Parameter password:      user password.
     - Parameter completion:    Response GigyaApiResult.
     */
    public func register(email: String, password: String, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        businessApiService.register(email: email, password: password, params: params, dataType: T.self, completion: completion)
    }

    /**
     Get account api

     - Parameter type:         Host data schema.
     - Parameter clearAccount: set true when you want to clear cache
     - Parameter completion:   Response GigyaApiResult<T>.
     */
    public func getAccount(_ clearAccount: Bool = false, completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.getAccount(clearAccount: clearAccount, dataType: T.self, completion: completion)
    }

    /**
     * Set account info.

     - Parameter account:      Host data obj.
     - Parameter completion:   Response GigyaApiResult<T>.
    */
    public func setAccount(with account: T, completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.setAccount(obj: account, completion: completion)
    }

    // MARK: - Native login

    /**
     Present social login selection list.

     - Parameter providers: List of selected social providers (GigyaSocielProviders).
     - Parameter params:    Request parameters.
     - Parameter completion:  Login response.
     */

    public func socialLoginWith(providers: [GigyaSocialProviders], viewController: UIViewController, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        businessApiService.login(providers: providers, viewController: viewController, params: params, completion: completion)
    }
    
    /**
     Add a social connection to current account.
     
     - Parameter providers: selected social provider (GigyaSocielProviders).
     - Parameter viewController: Shown view controller.
     - Parameter params:    Request parameters.
     - Parameter completion:  Login response.
     */
    
    public func addConnection(provider: GigyaSocialProviders, viewController: UIViewController, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.addConnection(provider: provider, viewController: viewController, params: params, dataType: T.self, completion: completion)
    }
    
    /**
     Remove a social connection from current account.
     
     - Parameter providers: selected social provider name.
     - Parameter completion:  Login response.
     */
    
    public func removeConnection(provider: GigyaSocialProviders, completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
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
    
    public func showScreenSet(with name: String, viewController: UIViewController, params: [String: Any] = [:], completion: @escaping (GigyaPluginEvent<T>) -> Void) {
        let wrapper = PluginViewWrapper(config: config, sessionService: sessionService, businessApiService: businessApiService, plugin: "accounts.screenSet", params: params, completion: completion)
        wrapper.presentPluginController(viewController: viewController, dataType: T.self, screenSet: name)
    }

    /**
     Show comments (ScreenSet)

     - Parameter params:   Comments ScreenSet parameters.
     - Parameter completion:  Plugin completion.
     */

//    private func showComments(viewController: UIViewController, params: [String: Any] = [:], completion: @escaping (PluginEvent<T>) -> Void) {
//        let wrapper = PluginViewWrapper(config: config, sessionService: sessionService, businessApiService: businessApiService, plugin: "comments.commentsUI", params: params, completion: completion)
//        wrapper.presentPluginController(viewController: viewController, dataType: T.self, screenSet: "")
//    }

    /**
     Update interruption handling.
     By default, the Gigya SDK will handle various API interruptions to allow simple resolving of certain common errors.
     Setting interruptions to FALSE will force the end user to handle his own errors.

     - Parameter sdkHandles: False if manually handling all errors.
     */
    public func handleInterruptions(sdkHandles: Bool) {
        interruptionResolver.setEnabled(sdkHandles)
    }

    /**
     Return SDK interruptions state.
     if TRUE, interruption handling will be optional via the GigyaLoginCallback.
     */
    public func interruptionsEnabled() -> Bool {
        return interruptionResolver.isEnabled
    }

}

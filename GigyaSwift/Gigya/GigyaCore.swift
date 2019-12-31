//
//  GigyaSW.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 10/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

/**
 The `GigyaCore` is the main interface for the SDK instance.
 Provides all access to Gigya services.

 When you use `Gigya.sharedInstance()` it will return an instance of `GigyaCore`.

 - warning: `GigyaCore` is designed to use a custom generic schema type (Default: `GigyaAccount`). If you are instantiating the core using your own schema (Example: `Gigya.sharedInstance(CustomSchema.self)`) it is required to add the specific schema every time you call to `Gigya.sharedInstance()`.
 */
public final class GigyaCore<T: GigyaAccountProtocol>: GigyaInstanceProtocol {

    // Default api domain
    private var defaultApiDomain: String {
        return InternalConfig.Storage.defaultApiDomain
    }

    // Initialize Dependencies
    public let config: GigyaConfig // TODO: Need to change to private, only for testing

    private let persistenceService: PersistenceService

    private let businessApiService: BusinessApiServiceProtocol

    private let sessionService: SessionServiceProtocol

    private let interruptionResolver: InterruptionResolverFactoryProtocol

    private lazy var pushService: PushNotificationsServiceProtocol = {
        return self.container.resolve(PushNotificationsServiceProtocol.self)!
    }()

    private let container: IOCContainer

    // MARK: - Biometric service

    /**
     Biometric service (TouchID / FaceID).

     - returns: `BiometricServiceProtocol` service
     */
    public let biometric: BiometricServiceProtocol

    // MARK: - Initialize

    internal init(config: GigyaConfig, persistenceService: PersistenceService, businessApiService: BusinessApiServiceProtocol, sessionService: SessionServiceProtocol, interruptionResolver: InterruptionResolverFactoryProtocol, biometric: BiometricServiceProtocol, plistFactory: PlistConfigFactory, container: IOCContainer) {
        self.config = config
        self.persistenceService = persistenceService
        self.businessApiService = businessApiService
        self.sessionService = sessionService
        self.interruptionResolver = interruptionResolver
        self.biometric = biometric
        self.container = container
        
        // load plist and make init
        let plistConfig = plistFactory.parsePlistConfig()

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

        businessApiService.getSDKConfig()
    }

    // MARK: - Anonymous API

    /**
     Send request to Gigya servers.

     - Parameter api:          Method identifier.
     - Parameter params:       Additional parameters.
     - Parameter completion:   Response `GigyaApiResult<GigyaDictionary>`.
     */

    public func send(api: String, params: [String: Any] = [:], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        businessApiService.send(api: api, params: params, completion: completion)
    }

    /**
     Send request with generic type.

     - Parameter api:         Method identifier.
     - Parameter params:      Additional parameters.
     - Parameter completion:  Response `GigyaApiResult<T>`.
     */

    public func send<B: Codable>(dataType: B.Type, api: String, params: [String: Any] = [:], completion: @escaping (GigyaApiResult<B>) -> Void ) {
        businessApiService.send(dataType: dataType, api: api, params: params, completion: completion)
    }


    // MARK: - Session

    /**
     * Check if the current session is valid which us adjacent to login status.
     */
    public func isLoggedIn() -> Bool {
        return sessionService.isValidSession()
    }

    /**
     Set session.

     - Parameter session:         GigyaSession object.
     */

    public func setSession(_ session: GigyaSession) {
        let sessionInfo = SessionInfoModel(sessionToken: session.token, sessionSecret: session.secret, sessionExpiration: String(describing: session.sessionExpirationTimestamp))
        sessionService.setSession(sessionInfo)
    }

    /**
     Logout of Gigya services.

     - Parameter completion:    Response `GigyaApiResult<GigyaDictionary>`.
     */
    public func logout(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        businessApiService.logout(completion: completion)
    }

    // MARK: - Business Api׳s

    /**
     Login api

     - Parameter loginId:      user identity.
     - Parameter password:     user password.
     - Parameter params:       Request parameters.
     - Parameter completion:   Response `GigyaLoginResult<T>`.
     */
    public func login(loginId: String, password: String, params: [String: Any] = [:], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        businessApiService.login(dataType: T.self, loginId: loginId, password: password, params: params, completion: completion)
    }

    /**
     Login with a 3rd party provider.

     - Parameter provider:          Social provider.
     - Parameter viewController:    Shown view controller.
     - Parameter params:            Request parameters.
     - Parameter completion:        Response `GigyaLoginResult<T>`.
     */
    public func login(with provider: GigyaSocialProviders, viewController: UIViewController,
                      params: [String: Any] = [:], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        businessApiService.login(provider: provider, viewController: viewController, params: params, dataType: T.self) { (res) in
            completion(res)
        }
    }

    /**
     Register account using email and password combination

     - Parameter email:         user email.
     - Parameter password:      user password.
     - Parameter params:        Request parameters.
     - Parameter completion:    Response `GigyaLoginResult<T>`.
     */
    public func register(email: String, password: String, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        businessApiService.register(email: email, password: password, params: params, dataType: T.self, completion: completion)
    }

    /**
     Request account info.

     - Parameter clearAccount: set true when you want to clear cache.
     - Parameter completion:   Response `GigyaApiResult<T>`.
     */
    public func getAccount(_ clearAccount: Bool = false, completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.getAccount(clearAccount: clearAccount, dataType: T.self, completion: completion)
    }

    /**
     Set account info.

     - Parameter account:      Schema type.
     - Parameter completion:   Response `GigyaApiResult<T>`.
    */
    public func setAccount(with account: T, completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.setAccount(obj: account, completion: completion)
    }


    /**
     Set account info given update parameters.

     - Parameter params:    Updated account parameters.
     - Parameter completion:   Response `GigyaApiResult<T>`.
    */
    public func setAccount(with params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.setAccount(params: params, completion: completion)
    }

    /**
     Send a reset email password to verified email attached to the users loginId.

     - Parameter loginId:    User login id.
     - Parameter completion:   Response `GigyaApiResult<GigyaDictionary>`.
    */

    public func forgotPassword(loginId: String, completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        var loginParams: [String: Any] = [:]
        loginParams["loginID"] = loginId

        businessApiService.forgotPassword(params: loginParams, completion: completion)
    }

    /**
     Send a reset email password to verified email attached to the users loginId.

     - Parameter params:        Request parameters, see [accounts.resetPassword REST](https://developers.gigya.com/display/GD/accounts.resetPassword+REST) for available parameters
     - Parameter completion:   Response `GigyaApiResult<GigyaDictionary>`.
    */

    public func forgotPassword(params: [String: Any], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        businessApiService.forgotPassword(params: params, completion: completion)
    }

    /**
     Login to with social provider when the provider session is available (obtained via specific provider login process).

     - Parameter params:       Request parameters.
     - Parameter completion:   Response `GigyaApiResult<T>`.
    */
    public func notifySocialLogin(params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.nativeSocialLogin(params: params, completion: completion)
    }
    // MARK: - Social Login

    /**
     Present social login selection list.

     - Parameter providers: List of selected social providers (`GigyaSocielProviders`).
     - Parameter viewController: Shown view controller.
     - Parameter params:    Request parameters.
     - Parameter completion:  Login response `GigyaLoginResult<T>`.
     */

    public func socialLoginWith(providers: [GigyaSocialProviders], viewController: UIViewController, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        businessApiService.login(providers: providers, viewController: viewController, params: params, completion: completion)
    }
    
    /**
     Add a social connection to current account.
     
     - Parameter providers: selected social provider (GigyaSocielProviders).
     - Parameter viewController: Shown view controller.
     - Parameter params:    Request parameters.
     - Parameter completion:  Login response `GigyaApiResult<T>`.
     */
    
    public func addConnection(provider: GigyaSocialProviders, viewController: UIViewController, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        businessApiService.addConnection(provider: provider, viewController: viewController, params: params, dataType: T.self, completion: completion)
    }
    
    /**
     Remove a social connection from current account.
     
     - Parameter providers: selected social provider name.
     - Parameter completion: Login response `GigyaApiResult<GigyaDictionary>`.
     */
    
    public func removeConnection(provider: GigyaSocialProviders, completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        businessApiService.removeConnection(providerName: provider, completion: completion)
    }

    // MARK: - Plugins

    /**
    Show ScreenSet

    - Parameter name:           ScreenSet name.
    - Parameter viewController: Shown view controller.
    - Parameter params:         General ScreenSet parameters.
    - Parameter completion:     Plugin completion `GigyaPluginEvent<T>`.
    */
    
    public func showScreenSet(with name: String, viewController: UIViewController, params: [String: Any] = [:], completion: @escaping (GigyaPluginEvent<T>) -> Void) {
        let webBridge = createWebBridge()

        let wrapper = PluginViewWrapper(config: config, persistenceService: persistenceService, sessionService: sessionService, businessApiService: businessApiService, webBridge: webBridge, plugin: "accounts.screenSet", params: params, completion: completion)
        wrapper.presentPluginController(viewController: viewController, dataType: T.self, screenSet: name)
    }

    // MARK: - Interruptions

    /**
     Return SDK interruptions state.
     if TRUE, interruption handling will be optional via the GigyaLoginCallback.
     */
    public var interruptionsEnabled: Bool {
        return interruptionResolver.isEnabled
    }

    /**
     Update interruption handling.
     By default, the Gigya SDK will handle various API interruptions to allow simple resolving of certain common errors.
     Setting interruptions to FALSE will force the end user to handle his own errors.

     - Parameter sdkHandles: False if manually handling all errors.
     */
    public func handleInterruptions(sdkHandles: Bool) {
        interruptionResolver.setEnabled(sdkHandles)
    }

    // MARK: - Web Bridge

    /**
     Create an new instance of the GigyaWebBridge.

     - returns: `GigyaWebBridge` instance.
     */

    public func createWebBridge() -> GigyaWebBridge<T> {
        let webBridge = container.resolve(GigyaWebBridge<T>.self)

        return webBridge!
    }

    // MARK: Push integration - Available in iOS 10+

    /**
     Recive Push

     - Parameter userInfo:   dictionary from didReceiveRemoteNotification.
     - Parameter completion:  Completion from didReceiveRemoteNotification.
     */

    @available(iOS 10.0, *)
    public func receivePush(userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        pushService.onReceivePush(userInfo: userInfo, completion: completion)
    }

    /**
     Foreground notification receive

     - Parameter data:   dictionary of message from didReceive:remoteMessage.
     */

    public func foregroundNotification(with data: [AnyHashable : Any]) {
        pushService.foregroundNotification(with: data)
    }

    /**
     Save push token ( from FCM )

     - Parameter key: FCM Key.
     */

    @available(iOS 10.0, *)
    public func updatePushToken(key: String) {
        pushService.savePushKey(key: key)
    }

    /**
     Request to Opt-In to Authentication.
     This is the first of two stages of the Opt-In process.

      - Parameter response: `UNNotificationResponse` from a tapped notification .
      */

    public func verifyPush(with response: UNNotificationResponse) {
        pushService.verifyPush(response: response.notification.request.content.userInfo)
    }

}

//
//  IOCBusinessApiServiceProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

public protocol BusinessApiServiceProtocol {
    var config: GigyaConfig { get }

    var apiService: ApiServiceProtocol { get }

    var sessionService: SessionServiceProtocol { get }

    var biometricService: BiometricServiceInternalProtocol { get }

    var accountService: AccountServiceProtocol { get }

    var socialProviderFactory: SocialProvidersManagerProtocol { get }

    init(config: GigyaConfig,
         persistenceService: PersistenceService,
         apiService: ApiServiceProtocol,
         sessionService: SessionServiceProtocol,
         accountService: AccountServiceProtocol,
         providerFactory: SocialProvidersManagerProtocol,
         interruptionsHandler: InterruptionResolverFactoryProtocol,
         biometricService: BiometricServiceInternalProtocol)

    func send(api: String, params: [String: Any], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)

    func send<T: Codable>(dataType: T.Type, api: String, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void)

    func getAccount<T: GigyaAccountProtocol>(params: [String: Any], clearAccount: Bool, dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void)

    func setAccount<T: GigyaAccountProtocol>(obj: T, completion: @escaping (GigyaApiResult<T>) -> Void)

    func setAccount<T: GigyaAccountProtocol>(params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void)
    
    func register<T: GigyaAccountProtocol>(email: String, password: String, params: [String: Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void)

    func login<T: GigyaAccountProtocol>(dataType: T.Type, loginId: String, password: String, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void)

    func login<T: GigyaAccountProtocol>(params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void)
    
    func login<T: GigyaAccountProtocol>(provider: GigyaSocialProviders, viewController: UIViewController, params: [String: Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void)

    func login<T: GigyaAccountProtocol>(providers: [GigyaSocialProviders], viewController: UIViewController, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void)

    func verifyLogin<T: GigyaAccountProtocol>(UID: String, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void)
    
    func addConnection<T: GigyaAccountProtocol>(provider: GigyaSocialProviders, viewController: UIViewController, params: [String: Any], dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void)
    
    func removeConnection(params: [String: Any], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)

    func removeConnection(providerName: GigyaSocialProviders, completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)
    
    func logout(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)

    func notifySocialLogin<T: GigyaAccountProtocol>(params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void)

    func forgotPassword(params: [String: Any], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)

    func isAvailable(loginId: String, completion: @escaping (GigyaApiResult<Bool>) -> Void)

    func getSchema(params: [String: Any], completion: @escaping (GigyaApiResult<GigyaSchema>) -> Void)
    
    func verifySession(params: [String: Any], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)
    
    func getAuthCode(completion: @escaping (GigyaApiResult<String>) -> Void)

    @available(iOS 13.0, *)
    func getSaptchaToken(completion: @escaping (GigyaApiResult<String>) -> Void)
}

//
//  IOCBusinessApiServiceProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol IOCBusinessApiServiceProtocol {
    var apiService: IOCApiServiceProtocol { get }

    var sessionService: IOCSessionServiceProtocol { get }

    var accountService: IOCAccountServiceProtocol { get }

    var socialProviderFactory: IOCSocialProvidersManagerProtocol { get }

    init(apiService: IOCApiServiceProtocol, sessionService: IOCSessionServiceProtocol,
         accountService: IOCAccountServiceProtocol, providerFactory: IOCSocialProvidersManagerProtocol)

    func send(api: String, params: [String: String], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)

    func send<T: Codable>(dataType: T.Type, api: String, params: [String: String], completion: @escaping (GigyaApiResult<T>) -> Void)

    func login<T: Codable>(dataType: T.Type, loginId: String, password: String, completion: @escaping (GigyaApiResult<T>) -> Void)

    func getAccount<T: Codable>(dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void)

    func setAccount<T: Codable>(obj: T, completion: @escaping (GigyaApiResult<T>) -> Void)
    
    func register<T: Codable>(params: [String: Any], dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void)

    func login<T: Codable>(provider: GigyaSocielProviders, viewController: UIViewController, params: [String: Any], dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void)
    
    func addConnection<T: Codable>(provider: GigyaSocielProviders, viewController: UIViewController, params: [String: Any], dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void)
    
    func removeConnection(providerName: String, completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)
    
    func logout(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)
    
}

//
//  GigyaApiServiceMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import Gigya

class BusinessApiServiceMock: BusinessApiService {
    var resData: Any?

    var showError: Bool = false

    required init(config: GigyaConfig, persistenceService: PersistenceService, apiService: ApiServiceProtocol, sessionService: SessionServiceProtocol, accountService: AccountServiceProtocol, providerFactory: SocialProvidersManagerProtocol, interruptionsHandler: InterruptionResolverFactoryProtocol, biometricService: BiometricServiceInternalProtocol) {
        super.init(config: config, persistenceService: persistenceService, apiService: apiService, sessionService: sessionService, accountService: accountService, providerFactory: providerFactory, interruptionsHandler: interruptionsHandler, biometricService: biometricService)

    }
//    required init(config: GigyaConfig, persistenceService: PersistenceService ,apiService: ApiServiceProtocol, sessionService: SessionServiceProtocol, accountService: AccountServiceProtocol, providerFactory: SocialProvidersManagerProtocol, interruptionsHandler: InterruptionResolverFactory, biometricService: BiometricServiceInternalProtocol) {
//        super.init(config: config, persistenceService: persistenceService, apiService: apiService, sessionService: sessionService, accountService: accountService, providerFactory: providerFactory, interruptionsHandler: interruptionsHandler, biometricService: biometricService)
//    }
//
//    override func send(api: String, params: [String: String] = [:], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
//        let requestMock = NetworkAdapterMock()
//        let requst = GigyaRequest(with: requestMock)
//
//        requestMock.data = resData as? NSData
//
//        requst.send(responseType: GigyaDictionary.self, completion: { (res) in
//            completion(res)
//        })
//
//    }
//
//    override func send<T: Codable>(dataType: T.Type, api: String, params: [String: String] = [:], completion: @escaping (GigyaApiResult<T>) -> Void) {
//        let requestMock = NetworkAdapterMock()
//        let requst = GigyaRequest(with: requestMock)
//
//        requestMock.data = resData as? NSData
//
//        requst.send(responseType: T.self, completion: { (res) in
//            completion(res)
//        })
//    }
//
//    override func login<T: Codable>(dataType: T.Type, loginId: String, password: String, completion: @escaping (GigyaApiResult<T>) -> Void) {
//        let requestMock = NetworkAdapterMock()
//        let requst = GigyaRequest(with: requestMock)
//
//        requestMock.data = resData as? NSData
//
//        requst.send(responseType: T.self, completion: { (res) in
//            if self.showError {
//                completion(.failure(.dataNotFound))
//            } else {
//                completion(res)
//            }
//        })
//    }
//
//    override func getAccount<T: Codable>(dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) {
//        let requestMock = NetworkAdapterMock()
//        let requst = GigyaRequest(with: requestMock)
//
//        requestMock.data = resData as? NSData
//
//        requst.send(responseType: T.self, completion: { (res) in
//            if self.showError {
//                completion(.failure(.dataNotFound))
//            } else {
//                completion(res)
//            }
//        })
//    }
}

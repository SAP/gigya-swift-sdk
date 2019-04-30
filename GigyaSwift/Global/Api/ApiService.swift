//
//  ApiManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol IOCApiServiceProtocol {
    var gigyaApi: IOCGigyaWrapperProtocol { get }

    var sessionService: IOCSessionServiceProtocol { get }

    var accountService: IOCAccountServiceProtocol { get }

    init(gigyaApi: IOCGigyaWrapperProtocol, sessionService: IOCSessionServiceProtocol, accountService: IOCAccountServiceProtocol)

    func send(api: String, params: [String: String], complition: @escaping (GigyaApiResult<GigyaDictionary>) -> Void)

    func send<T: Codable>(dataType: T.Type, api: String, params: [String: String], complition: @escaping (GigyaApiResult<T>) -> Void)

    func login<T: Codable>(dataType: T.Type, loginId: String, password: String, complition: @escaping (GigyaApiResult<T>) -> Void)

    func getAccount<T: Codable>(dataType: T.Type, complition: @escaping (GigyaApiResult<T>) -> Void)

    func register<T: Codable>(params: [String: Any], dataType: T.Type, complition: @escaping (GigyaApiResult<T>) -> Void)
}

class BusinessApiService: IOCApiServiceProtocol {

    let gigyaApi: IOCGigyaWrapperProtocol

    var sessionService: IOCSessionServiceProtocol

    var accountService: IOCAccountServiceProtocol

//    lazy var service: NetworkProvider = {
//        let service = NetworkProvider(url: appContext.config.apiDomain ?? InternalConfig.Storage.defaultApiDomain)
//        return service
//    }()d

    required init(gigyaApi: IOCGigyaWrapperProtocol, sessionService: IOCSessionServiceProtocol, accountService: IOCAccountServiceProtocol) {
        self.gigyaApi = gigyaApi
        self.sessionService = sessionService
        self.accountService = accountService
    }

    // Send regular request
    func send(api: String, params: [String: String] = [:], complition: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        let model = GigyaApiReguestModel(method: api, params: params)

        gigyaApi.send(model: model, responseType: GigyaDictionary.self, completion: complition)
    }

    // Send request with generic type.
    func send<T: Codable>(dataType: T.Type, api: String, params: [String: String] = [:], complition: @escaping (GigyaApiResult<T>) -> Void ) {
        let model = GigyaApiReguestModel(method: api, params: params)

        gigyaApi.send(model: model, responseType: T.self, completion: complition)

    }

    func login<T: Codable>(dataType: T.Type, loginId: String, password: String, complition: @escaping (GigyaApiResult<T>) -> Void) {
        let params = ["loginId": loginId, "password": password]
        let model = GigyaApiReguestModel(method: GigyaDefinitions.API.login, params: params)

        gigyaApi.send(model: model, responseType: T.self) { [weak accountService] result in
            switch result {
            case .success(let data):
                accountService?.account = data
                complition(result)
            case .failure:
                complition(result)
            }
        }
    }

    func getAccount<T: Codable>(dataType: T.Type, complition: @escaping (GigyaApiResult<T>) -> Void) {
        if accountService.isCachedAccount() {
            complition(.success(data: accountService.getAccount()))
        } else {
            let model = GigyaApiReguestModel(method: GigyaDefinitions.API.getAccountInfo)
            
            gigyaApi.send(model: model, responseType: T.self) { [weak accountService] result in
                switch result {
                case .success(let data):
                    accountService?.account = data
                    complition(result)
                case .failure:
                    complition(result)
                }
            }
        }
    }

    func register<T: Codable>(params: [String: Any], dataType: T.Type, complition: @escaping (GigyaApiResult<T>) -> Void) {
        let model = GigyaApiReguestModel(method: GigyaDefinitions.API.initRegistration)

        gigyaApi.send(model: model, responseType: [String: AnyCodable].self) { [weak gigyaApi] (result) in
            switch result {

            case .success(let data):
                let regToken = data["regToken"]?.value ?? ""
                let makeParams: [String: Any] = ["regToken": regToken, "finalizeRegistration": "true"].merging(params) { $1 }

                let model = GigyaApiReguestModel(method: GigyaDefinitions.API.register, params: makeParams)

                gigyaApi?.send(model: model, responseType: T.self, completion: complition)

            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    deinit {
        print("[ApiService]")
    }
}

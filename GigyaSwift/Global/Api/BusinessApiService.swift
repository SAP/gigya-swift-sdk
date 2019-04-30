//
//  ApiManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class BusinessApiService: NSObject, IOCBusinessApiServiceProtocol {

    let apiService: IOCApiServiceProtocol

    var sessionService: IOCSessionServiceProtocol

    var accountService: IOCAccountServiceProtocol

    var providerFactory: IOCProviderFactoryProtocol

    var providerAdapter: Provider?

    required init(apiService: IOCApiServiceProtocol, sessionService: IOCSessionServiceProtocol,
                  accountService: IOCAccountServiceProtocol, providerFactory: IOCProviderFactoryProtocol) {
        self.apiService = apiService
        self.sessionService = sessionService
        self.accountService = accountService
        self.providerFactory = providerFactory
    }

    // Send regular request
    func send(api: String, params: [String: String] = [:], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        let model = ApiRequestModel(method: api, params: params)

        apiService.send(model: model, responseType: GigyaDictionary.self, completion: completion)
    }

    // Send request with generic type.
    func send<T: Codable>(dataType: T.Type, api: String, params: [String: String] = [:], completion: @escaping (GigyaApiResult<T>) -> Void ) {
        let model = ApiRequestModel(method: api, params: params)

        apiService.send(model: model, responseType: T.self, completion: completion)

    }

    func login<T: Codable>(dataType: T.Type, loginId: String, password: String, completion: @escaping (GigyaApiResult<T>) -> Void) {
        let params = ["loginId": loginId, "password": password]
        let model = ApiRequestModel(method: GigyaDefinitions.API.login, params: params)

        apiService.send(model: model, responseType: T.self) { [weak accountService] result in
            switch result {
            case .success(let data):
                accountService?.account = data
                completion(result)
            case .failure:
                completion(result)
            }
        }
    }

    func getAccount<T: Codable>(dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) {
        if accountService.isCachedAccount() {
            completion(.success(data: accountService.getAccount()))
        } else {
            let model = ApiRequestModel(method: GigyaDefinitions.API.getAccountInfo)
            
            apiService.send(model: model, responseType: T.self) { [weak accountService] result in
                switch result {
                case .success(let data):
                    accountService?.account = data
                    completion(result)
                case .failure:
                    completion(result)
                }
            }
        }
    }

    func register<T: Codable>(params: [String: Any], dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) {
        let model = ApiRequestModel(method: GigyaDefinitions.API.initRegistration)

        apiService.send(model: model, responseType: [String: AnyCodable].self) { [weak self] (result) in
            switch result {

            case .success(let data):
                let regToken = data["regToken"]?.value ?? ""
                let makeParams: [String: Any] = ["regToken": regToken, "finalizeRegistration": "true"].merging(params) { $1 }

                let model = ApiRequestModel(method: GigyaDefinitions.API.register, params: makeParams)

                self?.apiService.send(model: model, responseType: T.self, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func login<T: Codable>(provider: GigyaSocielProviders, viewController: UIViewController,
                           params: [String: Any], dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) {
        providerAdapter = providerFactory.getProvider(with: provider, delegate: self)

        providerAdapter?.login(params: params, viewController: viewController, loginMode: "login") { (res) in
            completion(res)
        }

        providerAdapter?.didFinish = { [weak self] in
            self?.providerAdapter = nil
        }
    }

    func nativeSocialLogin<T: Codable>(params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        let model = ApiRequestModel(method: GigyaDefinitions.API.notifySocialLogin, params: params)

        apiService.send(model: model, responseType: T.self) { [weak self] result in
            switch result {
            case .success:
                self?.getAccount(dataType: T.self, completion: completion)
            case .failure:
                completion(result)
            }
        }
    }

    deinit {
        print("[BusinessService]")
    }
}

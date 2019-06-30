//
//  ApiManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

class BusinessApiService: NSObject, IOCBusinessApiServiceProtocol {

    let apiService: IOCApiServiceProtocol

    var sessionService: IOCSessionServiceProtocol

    var config: GigyaConfig

    var accountService: IOCAccountServiceProtocol

    var socialProviderFactory: IOCSocialProvidersManagerProtocol

    var providerAdapter: Provider?

    var interruptionsHandler: IOCInterruptionResolverFactory

    var providersFactory: ProvidersLoginWrapper?

    required init(config: GigyaConfig, apiService: IOCApiServiceProtocol, sessionService: IOCSessionServiceProtocol,
                  accountService: IOCAccountServiceProtocol, providerFactory: IOCSocialProvidersManagerProtocol,
                  interruptionsHandler: IOCInterruptionResolverFactory) {
        self.config = config
        self.apiService = apiService
        self.sessionService = sessionService
        self.accountService = accountService
        self.socialProviderFactory = providerFactory
        self.interruptionsHandler = interruptionsHandler
    }

    // Send regular request
    func send(api: String, params: [String: Any] = [:], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        let model = ApiRequestModel(method: api, params: params)

        apiService.send(model: model, responseType: GigyaDictionary.self, completion: completion)
    }

    // Send request with generic type.
    func send<T: Codable>(dataType: T.Type, api: String, params: [String: Any] = [:], completion: @escaping (GigyaApiResult<T>) -> Void ) {
        let model = ApiRequestModel(method: api, params: params)

        apiService.send(model: model, responseType: T.self, completion: completion)
    }

    func getAccount<T: Codable>(clearAccount: Bool = false, dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) {
        if clearAccount == true {
            accountService.clear()
        }

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

    func setAccount<T: Codable>(obj: T, completion: @escaping (GigyaApiResult<T>) -> Void) {
        let diffParams = accountService.setAccount(newAccount: obj)
        let model = ApiRequestModel(method: GigyaDefinitions.API.setAccountInfo, params: diffParams)

        apiService.send(model: model, responseType: GigyaDictionary.self) { [weak self] result in
            switch result {
            case .success:
                self?.accountService.clear()
                self?.getAccount(dataType: T.self, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func setAccount<T: Codable>(params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        let model = ApiRequestModel(method: GigyaDefinitions.API.setAccountInfo, params: params)

        apiService.send(model: model, responseType: T.self) { result in
            switch result {
            case .success(let data):
                completion(.success(data: data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func register<T: GigyaAccountProtocol>(email: String, password: String, params: [String: Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        let model = ApiRequestModel(method: GigyaDefinitions.API.initRegistration)

        apiService.send(model: model, responseType: [String: AnyCodable].self) { [weak self] (result) in
            switch result {
            case .success(let data):
                let regToken = data["regToken"]?.value ?? ""
                let makeParams: [String: Any] = ["email": email,"password": password, "regToken": regToken, "finalizeRegistration": "true"].merging(params) { $1 }

                let model = ApiRequestModel(method: GigyaDefinitions.API.register, params: makeParams)

                self?.apiService.send(model: model, responseType: T.self) { result in
                    switch result {
                    case .success(let data):
                        completion(.success(data: data))

                        self?.clearOptionalObjects()
                    case .failure(let error):
                        self?.interruptionResolver(error: error, completion: completion)
                    }
                }

            case .failure(let error):
                let loginError = LoginApiError<T>(error: error, interruption: nil)
                completion(.failure(loginError))
            }
        }
    }

    func login<T: GigyaAccountProtocol>(dataType: T.Type, loginId: String, password: String, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        var mutatedParams = params
        mutatedParams["loginID"] = loginId
        mutatedParams["password"] = password
        
        let model = ApiRequestModel(method: GigyaDefinitions.API.login, params: mutatedParams)

        apiService.send(model: model, responseType: T.self) { [weak self] result in
            switch result {
            case .success(let data):
                self?.accountService.account = data

                completion(.success(data: data))

                self?.clearOptionalObjects()
            case .failure(let error):
                self?.interruptionResolver(error: error, completion: completion)
            }
        }
    }

    func login<T: GigyaAccountProtocol>(provider: GigyaSocialProviders, viewController: UIViewController,
                           params: [String: Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        providerAdapter = socialProviderFactory.getProvider(with: provider, delegate: self)

        providerAdapter?.login(type: T.self, params: params, viewController: viewController, loginMode: "standart") { (result) in
            switch result {
            case .success(let data):
                completion(.success(data: data))
            case .failure(let error):
                self.interruptionResolver(error: error, completion: completion)
            }
        }

        providerAdapter?.didFinish = { [weak self] in
            self?.clearOptionalObjects()
        }
    }

    func login<T: GigyaAccountProtocol>(providers: [GigyaSocialProviders], viewController: UIViewController, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        providersFactory = ProvidersLoginWrapper(config: config, providers: providers)
        providersFactory?.show(params: params, viewController: viewController) { [weak self] json, error in
            if let providerString = json?["provider"] as? String,
               let provider = GigyaSocialProviders(rawValue: providerString) {
                self?.login(provider: provider, viewController: viewController, params: params, dataType: T.self) {  [weak self] result in
                    switch result {
                    case .success:
                        self?.dismissProvidersLogin()
                    case .failure(let errorObject):
                        guard case .providerError = errorObject.error else {
                            self?.dismissProvidersLogin()
                            completion(result)
                            return
                        }
                    }
                    completion(result)
                }
            }
        }
    }

    func nativeSocialLogin<T: Codable>(params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        let model = ApiRequestModel(method: GigyaDefinitions.API.notifySocialLogin, params: params)

        apiService.send(model: model, responseType: GigyaDictionary.self) { [weak self] result in
            switch result {
            case .success:
                self?.getAccount(dataType: T.self, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addConnection<T: GigyaAccountProtocol>(provider: GigyaSocialProviders, viewController: UIViewController, params: [String: Any], dataType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) {
        GigyaLogger.log(with: self, message: "[addConnection] - start")

        providerAdapter = socialProviderFactory.getProvider(with: provider, delegate: self)
        providerAdapter?.login(type: T.self, params: params, viewController: viewController, loginMode: "connect") { (res) in
            completion(res)

            GigyaLogger.log(with: self, message: "[addConnection] - finish: \(res)")
        }
        
        providerAdapter?.didFinish = { [weak self] in
            self?.clearOptionalObjects()
        }
    }
    
    func removeConnection(providerName: GigyaSocialProviders, completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        let params = ["provider": providerName.rawValue]

        GigyaLogger.log(with: self, message: "[removeConnection]: params: \(params)")

        let model = ApiRequestModel(method: GigyaDefinitions.API.removeConnection, params: params)
        apiService.send(model: model, responseType: GigyaDictionary.self, completion: completion)
    }
    
    func logout(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        GigyaLogger.log(with: self, message: "[logout]")

        let model = ApiRequestModel(method: GigyaDefinitions.API.logout, params: nil)
        apiService.send(model: model, responseType: GigyaDictionary.self, completion: completion)
    }

    func finalizeRegistration<T: Codable>(regToken: String, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        let params = ["regToken": regToken, "include": "profile,data,emails,subscriptions,preferences", "includeUserInfo": "true"]

        GigyaLogger.log(with: self, message: "[finalizeRegistration] - params: \(params)")

        send(dataType: T.self, api: GigyaDefinitions.API.finalizeRegistration, params: params) { result in
            switch result {
            case .success(let data):
                completion(.success(data: data))

                GigyaLogger.log(with: BusinessApiService.self, message: "[finalizeRegistration] - success")
            case .failure(let error):
                let loginError = LoginApiError<T>(error: error, interruption: nil)

                GigyaLogger.log(with: BusinessApiService.self, message: "[finalizeRegistration] - failure: \(error)")

                completion(.failure(loginError))
            }
        }
    }

    private func interruptionResolver<T: GigyaAccountProtocol>(error: NetworkError, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        interruptionsHandler.resolve(error: error, businessDelegate: self, completion: completion)
    }

    private func clearOptionalObjects() {
        self.providerAdapter = nil
    }

    private func dismissProvidersLogin() {
        self.providersFactory?.dismiss()
        self.providersFactory = nil
    }

}

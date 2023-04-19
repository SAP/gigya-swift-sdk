//
//  OauthService.swift
//  Gigya
//
//  Created by Sagi Shmuel on 05/07/2022.
//  Copyright © 2022 Gigya. All rights reserved.
//

import Foundation

class OauthService {
    let businessApiService: BusinessApiServiceProtocol
    var params: [String: Any] = [:]

    init(businessApiService: BusinessApiServiceProtocol) {
        self.businessApiService = businessApiService
    }
    
    func connect(token: String, completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        var model = ApiRequestModel(method: GigyaDefinitions.Oauth.connect)
        model.headers = ["Authorization": "Bearer \(token)"]
        businessApiService.apiService.send(model: model, responseType: GigyaDictionary.self) { result in
            completion(result)
        }
    }
    
    @available(iOS 13.0.0, *)
    func authorize<T: Codable>(token: String) async -> GigyaLoginResult<T> {
        return await withCheckedContinuation { [weak self] continuation in
            guard let self = self else { return }
            
            var model = ApiRequestModel(method: GigyaDefinitions.Oauth.authorize, params: ["response_type": "code"])
            model.headers = ["Authorization": "Bearer \(token)"]
            
            self.businessApiService.apiService.send(model: model, responseType: GigyaDictionary.self) { result in
                switch result {
                case .success(data: let data):
                    self.token(continuation: continuation, code: data["code"]?.value as! String)
                case .failure(let error):
                    continuation.resume(returning: GigyaLoginResult.failure(.init(error: error)))
                }
            }
        }
        
    }
    
    @available(iOS 13.0.0, *)
    private func token<T: Codable>(continuation: CheckedContinuation<GigyaLoginResult<T>, Never>, code: String) {
        var params: [String: Any] = ["grant_type": "authorization_code", "code": code]
        params.merge(params) { _, new  in new }
        
        self.businessApiService.send(dataType: T.self, api: GigyaDefinitions.Oauth.token, params: params) { [weak self] res in
            guard let self = self else { return }

            switch res {
            case .success(data: _):
                
                self.businessApiService.getAccount(params: [:], clearAccount: true, dataType: T.self) { result in
                    switch result {
                    case .success(data: let data):
                        continuation.resume(returning: .success(data: data))
                    case .failure(let error):
                        continuation.resume(returning: .failure(LoginApiError.init(error: error)))
                    }
                }
            case .failure(let error):
                continuation.resume(returning: .failure(LoginApiError.init(error: error)))
            }
        }
    }
}


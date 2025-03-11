//
//  SaptchaService.swift
//  GigyaSwift
//
//  Created by Sagi Shmuel on 04/03/2025.
//  Copyright © 2025 Gigya. All rights reserved.
//

final class SaptchaService {
    let businessApiService: BusinessApiServiceProtocol
    let saptchaUtils: SaptchaUtils

    init(businessApiService: BusinessApiServiceProtocol, saptchaUtils: SaptchaUtils) {
        self.businessApiService = businessApiService
        self.saptchaUtils = saptchaUtils
    }
    
    @available(iOS 13.0, *)
    func startChallenge(completion: @escaping (GigyaApiResult<String>) -> Void)  {
        let model = ApiRequestModel(method: GigyaDefinitions.Saptcha.getChallenge)
        businessApiService.apiService.send(model: model, responseType: GigyaDictionary.self) { [weak self] result in
            switch result {
            case .success(data: let data):
                let token = data["saptchaToken"]?.value as? String ?? ""
                self?.verifyChallenge(token: token , completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func verifyChallenge(token: String, completion: @escaping (GigyaApiResult<String>) -> Void)  {
        let verifyAlgo = saptchaUtils.verifySaptcha(jwt: token)
        let params = ["token": "\(token)|\(verifyAlgo)"]
        let model = ApiRequestModel(method: GigyaDefinitions.Saptcha.verify, params: params)
        
        businessApiService.apiService.send(model: model, responseType: GigyaDictionary.self) { result in
            switch result {
            case .success(data: let data):
                let saptchaToken = data["saptchaToken"]?.value as? String ?? ""
                completion(.success(data: saptchaToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

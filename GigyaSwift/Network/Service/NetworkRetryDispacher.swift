//
//  NetworkRetryDispacher.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 29/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class NetworkRetryDispacher<T: Codable> {
    weak var apiSevice: ApiService?

    private var retrys = 0
    private let maxRetry = 2

    private let tmpModel: ApiRequestModel?

    init(apiSevice: ApiService, tmpModel: ApiRequestModel) {
        self.apiSevice = apiSevice
        self.tmpModel = tmpModel
    }

    func startRery(completion: @escaping (GigyaApiResult<T>) -> Void) {

        // retry when the error is request expired
        if retrys < maxRetry {
            retrys += 1

            apiSevice?.send(model: tmpModel!, fromExpiring: true, responseType: T.self, completion: { result in
                switch result {
                case .success:
                    completion(result)
                case .failure(let error):
                    switch error {
                    case .gigyaError(let data):
                        if self.retrys == self.maxRetry {
                            completion(result)
                            return
                        }

                        if data.errorCode == GigyaDefinitions.ErrorCode.requestExpired {
                            self.startRery(completion: completion)
                        }
                    default:
                        completion(result)
                    }
                }
            })
        }
    }

}

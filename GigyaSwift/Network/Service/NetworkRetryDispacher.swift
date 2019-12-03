//
//  NetworkRetryDispacher.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 29/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

final class NetworkRetryDispacher<T: Codable> {

    private let networkAdapter: NetworkAdapterProtocol?

    private var retrys = 0
    private let maxRetry = 2

    private let tmpModel: ApiRequestModel?

    init(networkAdapter: NetworkAdapterProtocol?, tmpModel: ApiRequestModel) {
        self.networkAdapter = networkAdapter
        self.tmpModel = tmpModel
    }

    func startRetry(completion: @escaping (NSData?) -> Void) {

        // retry when the error is request expired
        if retrys < maxRetry {
            retrys += 1

            networkAdapter?.send(model: tmpModel!, blocking: false, completion: { (data, error) in
                guard let data = data else { return }

                let objData = DecodeEncodeUtils.dataToDictionary(data: data as Data) as [String: Any]

                if self.retrys == self.maxRetry {
                    completion(data)
                    return
                }

                if let errorCode = objData["errorCode"] as? Int, errorCode == GigyaDefinitions.ErrorCode.requestExpired {
                    self.startRetry(completion: completion)
                } else {
                    completion(data)
                }
            })
        }
    }

}

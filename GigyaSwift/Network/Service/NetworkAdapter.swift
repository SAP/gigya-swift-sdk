//
//  GSRequestWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 20/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSDK

public typealias GigyaResponseHandler = (NSData?, Error?) -> Void

protocol IOCNetworkAdapterProtocol {
    func send(model: ApiRequestModel, completion: @escaping GigyaResponseHandler)
}

class NetworkAdapter: IOCNetworkAdapterProtocol {
    let config: GigyaConfig

    let sessionService: IOCSessionServiceProtocol

    private let serial = DispatchQueue(label: "httpRequests")

    init(config: GigyaConfig, sessionService: IOCSessionServiceProtocol) {
        self.config = config
        self.sessionService = sessionService
    }

    func send(model: ApiRequestModel, completion: @escaping GigyaResponseHandler) {
        serial.async { [weak self] in
            guard let self = self else {
                completion(nil, nil)
                return
            }

            let networkService = NetworkProvider(url: self.config.apiDomain, config: self.config)

            networkService.dataRequest(gsession: self.sessionService.session, path: model.method, params: model.params as? [String : String], completion: { (data, error) in
                completion(data, error)
            })
        }
    }
}

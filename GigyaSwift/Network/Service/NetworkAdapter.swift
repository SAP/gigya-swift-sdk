//
//  GSRequestWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 20/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public typealias GigyaResponseHandler = (NSData?, Error?) -> Void

public protocol NetworkAdapterProtocol {
    func send(model: ApiRequestModel, completion: @escaping GigyaResponseHandler)
}

class NetworkAdapter: NetworkAdapterProtocol {
    let config: GigyaConfig

    let persistenceService: PersistenceService

    let sessionService: SessionServiceProtocol

    private let serial = DispatchQueue(label: "httpRequests")

    init(config: GigyaConfig, persistenceService: PersistenceService, sessionService: SessionServiceProtocol) {
        self.config = config
        self.persistenceService = persistenceService
        self.sessionService = sessionService
    }

    func send(model: ApiRequestModel, completion: @escaping GigyaResponseHandler) {
        serial.async { [weak self] in
            guard let self = self else {
                completion(nil, nil)
                return
            }

            let networkService = NetworkProvider(url: self.config.apiDomain, config: self.config, persistenceService: self.persistenceService)

            networkService.dataRequest(gsession: self.sessionService.session, path: model.method, params: model.params, completion: { (data, error) in
                completion(data, error)
            })
        }
    }
}

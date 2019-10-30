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
    func send(model: ApiRequestModel, blocking: Bool, completion: @escaping GigyaResponseHandler)

    func release()
}

class NetworkAdapter: NetworkAdapterProtocol {
    let config: GigyaConfig

    let persistenceService: PersistenceService

    let sessionService: SessionServiceProtocol

    private var queueHelper: NetworkBlockingQueueUtils

    init(config: GigyaConfig, persistenceService: PersistenceService, sessionService: SessionServiceProtocol, queueHelper: NetworkBlockingQueueUtils) {
        self.config = config
        self.persistenceService = persistenceService
        self.sessionService = sessionService
        self.queueHelper = queueHelper
    }

    func send(model: ApiRequestModel, blocking: Bool = false, completion: @escaping GigyaResponseHandler) {
        let opertaion = BlockOperation {
            let networkService = NetworkProvider(url: self.config.apiDomain, config: self.config, persistenceService: self.persistenceService)

            networkService.dataRequest(gsession: self.sessionService.session, path: model.method, params: model.params, completion: { (data, error) in
                completion(data, error)
            })
        }

        if queueHelper.blockingState {
            queueHelper.add(block: opertaion)
            return
        }

        queueHelper.runWith(block: opertaion)

        queueHelper.blockingState = blocking
    }

    func release() {
        queueHelper.release()
    }
}

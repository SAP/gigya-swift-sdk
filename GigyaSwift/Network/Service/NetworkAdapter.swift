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
}

class NetworkAdapter: NetworkAdapterProtocol {

    let networkProvider: NetworkProvider

    var queueHelper: NetworkBlockingQueueUtils

    // remove all dependencies and add 'NetworkProvider' to constructor
    init(networkProvider: NetworkProvider, queueHelper: NetworkBlockingQueueUtils) {
        self.networkProvider = networkProvider
        self.queueHelper = queueHelper
    }

    func send(model: ApiRequestModel, blocking: Bool = false, completion: @escaping GigyaResponseHandler) {

        queueHelper.add(block:
            BlockOperation {
                // forword only model
                GigyaLogger.log(with: self, message: "Start: \(model.method)")
                self.networkProvider.dataRequest(model: model, completion: { (data, error) in
                    completion(data, error)

                    if blocking {
                        self.release()
                    }
                })
            }
        )

        if blocking {
            queueHelper.lock()
        }
    }

    private func release() {
        queueHelper.release()
    }
}

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

    init(config: GigyaConfig) {
        self.config = config
    }

    func send(model: ApiRequestModel, completion: @escaping GigyaResponseHandler) {
        let request = GSRequest(forMethod: model.method, parameters: model.params)

//        let request1 = NetworkProvider(url: InternalConfig.General.sdkDomain, config: config)

        request.send { (res, error) in
            let data = res?.jsonString().data(using: .utf8) as NSData?
            completion(data, error)
        }
    }
}

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

public protocol IOCNetworkAdapterProtocol {
    func send(model: ApiRequestModel, completion: @escaping GigyaResponseHandler)
}

class NetworkAdapter: IOCNetworkAdapterProtocol {
    func send(model: ApiRequestModel, completion: @escaping GigyaResponseHandler) {
        let request = GSRequest(forMethod: model.method, parameters: model.params)

        request.send { (res, error) in
            let data = res?.jsonString().data(using: .utf8) as NSData?
            completion(data, error)
        }
    }
}

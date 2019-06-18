//
//  IOCApiServiceProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public protocol IOCApiServiceProtocol {
    init(with requst: IOCNetworkAdapterProtocol)

    func send<T: Codable & Any>(model: ApiRequestModel, responseType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void)
}

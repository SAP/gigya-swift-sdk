//
//  IOCApiServiceProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public protocol ApiServiceProtocol {
    
    init(with requst: NetworkAdapterProtocol, session: SessionServiceProtocol, persistenceService: PersistenceService)

    func sendBlocking<T: Codable & Any>(model: ApiRequestModel, responseType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void)

    func send<T: Codable & Any>(model: ApiRequestModel, responseType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void)

    func getSDKConfig()

}

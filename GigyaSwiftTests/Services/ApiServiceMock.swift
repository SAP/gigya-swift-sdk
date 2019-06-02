//
//  ApiServiceMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 17/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import GigyaSwift

class ApiServiceMock: IOCApiServiceProtocol {
    required init(with requst: IOCNetworkAdapterProtocol, session: IOCSessionServiceProtocol) {

    var resData: Any?

    var showError: Bool = false

    let request: IOCNetworkAdapterProtocol?

    required init(with requst: IOCNetworkAdapterProtocol) {
        self.request = requst
    }

    // Send request to server
    func send<T: Codable & Any>(model: ApiRequestModel, responseType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) {
        
    }


}

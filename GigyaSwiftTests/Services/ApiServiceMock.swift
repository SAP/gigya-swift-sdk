//
//  ApiServiceMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 17/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import Gigya

class ApiServiceMock: ApiServiceProtocol {

    var resData: Any?

    var showError: Bool = false

    let request: NetworkAdapterProtocol?

    let sessionService: SessionServiceProtocol

    required init(with requst: NetworkAdapterProtocol, session: SessionServiceProtocol) {
        self.request = requst
        self.sessionService = session
    }

    // Send request to server
    func send<T: Codable & Any>(model: ApiRequestModel, responseType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) {
        
    }


}

//
//  GigyaApiRequestMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 26/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import GigyaSwift

class NetworkAdapterMock: NetworkAdapter {

    var data: NSData?
    var error: Error?

    init() {
        let model = GigyaApiReguestModel(method: "mock")
        let provider = GSRequestMock(forMethod: model.method)
        super.init(with: provider)
    }

    override func send(_ complition: @escaping GigyaResponseHandler) {
        complition(data, error)
    }
}

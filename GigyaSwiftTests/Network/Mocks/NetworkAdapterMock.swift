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

    override func send(model: ApiRequestModel, completion: @escaping GigyaResponseHandler) {
        //swiftlint:disable:next force_cast
        let data = ResponseDataTest.resData as? NSData ?? nil
        completion(data, ResponseDataTest.getError())
    }
}

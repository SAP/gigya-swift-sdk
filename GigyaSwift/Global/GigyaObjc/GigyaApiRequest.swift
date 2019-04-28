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

open class NetworkAdapter {
    let request: GSRequest

    init(with request: GSRequest) {
        self.request = request
    }

    open func send(_ complition: @escaping GigyaResponseHandler) {
        self.request.send { (res, error) in
            complition(res?.data, error)
        }
    }
}

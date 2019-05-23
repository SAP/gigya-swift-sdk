//
//  WebProviderMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 22/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import GigyaSwift

class WebProviderWrapperMock: NSObject, ProviderWrapperProtocol {
    var clientID: String? = {
        return ResponseDataTest.clientID
    }()

    required override init() {
        super.init()
    }

    func login(params: [String: Any]?, viewController: UIViewController?, completion: @escaping ([String: Any]?, String?) -> Void) {
        var data: [String: String] = ["accessToken": ResponseDataTest.providerToken ?? "", "providerSecret": ResponseDataTest.providerSecret ?? ""]

        if let secret = ResponseDataTest.providerSecret {
            data["tokenSecret"] = secret
        }

        completion(data, ResponseDataTest.providerError)
    }
}


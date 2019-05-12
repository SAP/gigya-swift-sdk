//
//  GoogleProviderMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import GigyaSwift

class SocialProviderWrapperMock: NSObject, ProviderWrapperProtocol {

    var clientID: String? = {
        return ResponseDataTest.clientID
    }()

    required override init() {
        super.init()
    }

    func login(params: [String: Any]?, viewController: UIViewController?, completion: @escaping ([String: Any]?, String?) -> Void) {
            let data: [String: String] = ["accessToken": ResponseDataTest.providerToken ?? "", "providerSecret": ResponseDataTest.providerSecret ?? ""]
        completion(data, ResponseDataTest.providerError)
    }
}

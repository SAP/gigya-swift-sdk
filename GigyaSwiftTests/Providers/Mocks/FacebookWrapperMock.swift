//
//  FacebookWrapperMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import GigyaSwift

class FacebookWrapperMock: ProviderWrapperProtocol {

    var clientID: String? = {
        return ResponseDataTest.clientID
    }()

    func login(params: [String: Any]? = nil, viewController: UIViewController? = nil, completion: @escaping (String?, String?, String?) -> Void) {
        completion(ResponseDataTest.providerToken, ResponseDataTest.providerSecret, ResponseDataTest.providerError)
    }

    func logout() {

    }
}

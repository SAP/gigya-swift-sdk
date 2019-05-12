//
//  GoogleProviderMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import GigyaSwift

class SocialProviderWrapperMock: SocialLoginProvider {

    var clientID: String? = {
        return ResponseDataTest.clientID
    }()

        func login(params: [String : Any]?, viewController: UIViewController?, completion: @escaping ([String: Any]?, String?) -> Void) {
            let data: [String: Any] = ["": ResponseDataTest.providerToken, "": ResponseDataTest.providerSecret]
        completion(data, ResponseDataTest.providerError)
    }
}

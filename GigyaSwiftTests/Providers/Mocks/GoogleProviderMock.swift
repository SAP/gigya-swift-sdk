//
//  GoogleProviderMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import GigyaSwift

class GoogleProviderMock: GoogleProvider {
    func loginSuccess<T>(providerSessions: String, loginMode: String, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
//        let data: [String: Any] = ["callId": "123", "errorCode": 0]
        //swiftlint:disable:next force_cast
        completion(.success(data: ResponseDataTest.resData as! T))
    }
}

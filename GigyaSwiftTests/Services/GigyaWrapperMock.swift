//
//  GigyaWarpperMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import Gigya

class GigyaWrapperMock: GigyaWrapper {

//    override func send<T>(model: ApiRequestModel, responseType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) {
//        guard let response = ResponseDataTest.resData else {
//            completion(.failure(.dataNotFound))
//            return
//        }
//
//        if let responseCasting = response as? T {
//            completion(.success(data: responseCasting))
//        } else {
//            //swiftlint:disable:next force_cast
//            completion(.success(data: [:] as! T))
//        }
//    }

    override func isValidSession() -> Bool {
        return false
    }
}

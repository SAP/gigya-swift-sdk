//
//  ResponseDataGlobal.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 02/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class ResponseDataTest {
    static var resData: Any?
    static var providerToken: String?
    static var providerSecret: String?
    static var providerError: String?
    static var clientID: String?
    static var error: Error?

    static func getError() -> Error? {
        ResponseDataTest.errorCalled += 1
        if ResponseDataTest.errorCalled >= 2 {
            ResponseDataTest.error = nil
            changeErrorToZero()
        }
        return ResponseDataTest.error
    }

    static func changeErrorToZero() {
        // swiftlint:disable force_try
        let data = self.resData as? Data ?? Data()
        do {
            var jsonArray = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)  as! [String: AnyObject]

            jsonArray["errorCode"] = 0 as AnyObject

            let jsonData = try! JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            ResponseDataTest.resData = jsonData
        } catch {
            
        }
    }

    static var errorCalled: Int = 0
}

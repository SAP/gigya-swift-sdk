//
//  DecodeUtils.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import Gigya

class DecodeTestUtils {
    static func toObject<D, T: Codable>(data: D, toType: T.Type) throws -> T {
        let objData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let decode = try DecodeEncodeUtils.decode(fromType: T.self, data: objData)

        return decode
    }
}

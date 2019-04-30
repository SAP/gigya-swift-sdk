//
//  RequestTestParseFailModel.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 21/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct RequestTestParseFailModel: Codable {
    let callID: String
    let errorCode: Int
    let statusCode: Int
}

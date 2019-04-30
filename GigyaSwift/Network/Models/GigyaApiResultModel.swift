//
//  GigyaApiResultModel.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 20/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public struct ApiResultModel: Codable {
    let statusCode: GigyaApiStatusCode
    let errorCode: Int
    let callId: String
}

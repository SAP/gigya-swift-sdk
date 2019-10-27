//
//  SessionInfoModel.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 29/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public struct SessionInfoModel: Codable {
    let sessionToken: String?
    let sessionSecret: String?
    let sessionExpiration: String?

    private enum CodingKeys: String, CodingKey {
        case sessionToken = "sessionToken"
        case sessionSecret = "sessionSecret"
        case sessionExpiration = "expires_in"
    }
}

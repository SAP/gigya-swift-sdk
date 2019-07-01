//
//  SessionInfoModel.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 29/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct SessionInfoModel: Codable {
    let sessionToken: String
    let sessionSecret: String

    private enum CodingKeys: String, CodingKey {
        case sessionToken = "sessionToken"
        case sessionSecret = "sessionSecret"
    }
}

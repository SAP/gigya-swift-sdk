//
//  GigyaPlistConfig.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 17/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct PlistConfig: Decodable {
    let apiKey: String?
    let apiDomain: String?
    let touchIDText: String?
    let sessionVerificationInterval: Double?

    private enum CodingKeys: String, CodingKey {
        case apiKey = "GigyaApiKey"
        case apiDomain = "GigyaApiDomain"
        case touchIDText = "GigyaTouchIDMessage"
        case sessionVerificationInterval = "GigyaSessionVerificationInterval"
    }
}

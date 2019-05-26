//
//  RequestSignature.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 25/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct GigyaRequestSignature: Codable {
    var apikey: String
    var format: String = "json"
    var gmid: String
    var httpStatusCodes: String = "false"
    var nonce: String
    var oauthToken: String
    var sdk: String = "iOS_3.6.11"
    var targetEnv: String = "mobile"
    var timestamp: String
    var ucid: String

    init(oauthToken: String, apikey: String, nonce: String, timestamp: String, ucid: String, gmid: String) {
        self.oauthToken = oauthToken
        self.apikey = apikey
        self.nonce = nonce
        self.timestamp = timestamp
        self.ucid = ucid
        self.gmid = gmid
    }

    private enum CodingKeys: String, CodingKey {
        case oauthToken = "oauth_token"
        case apikey
        case nonce
        case timestamp
        case ucid
        case gmid
        case targetEnv
        case sdk
        case httpStatusCodes
        case format
    }

}

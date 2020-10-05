//
//  RequestSignature.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 25/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct GigyaRequestSignature: Codable {
    var apikey: String?
    var format: String = "json"
    var gmid: String?
    var ucid: String?
    var httpStatusCodes: String = "false"
    var oauthToken: String?
    var sdk: String = InternalConfig.General.version
    var targetEnv: String = "mobile"

    var nonce: String?
    var timestamp: String?

    init(oauthToken: String?, apikey: String, nonce: String?, timestamp: String?, ucid: String?, gmid: String?) {
        self.oauthToken = oauthToken
        self.nonce = nonce
        self.timestamp = timestamp
        self.ucid = ucid
        self.gmid = gmid

        if oauthToken == nil {
            self.apikey = apikey
        }
    }

    init(apikey: String, ucid: String?, gmid: String?) {
        self.apikey = apikey
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

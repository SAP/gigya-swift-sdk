////
////  RequestSignature.swift
////  GigyaSwift
////
////  Created by Shmuel, Sagi on 25/03/2019.
////  Copyright © 2019 Gigya. All rights reserved.
////
//
//import Foundation
//
//struct GigyaRequestSignature: Codable {
//    var oauthToken: String
//    var apikey: String
//    var nonce: String
//    var timestamp: String
//    var ucid: String
//    var gmid: String
//    var targetEnv: String = "mobile"
//    var sdk: String = "iOS_3.6.10"
//    var httpStatusCodes: String = "false"
//    var format: String = "json"
//
//    init(oauthToken: String, apikey: String, nonce: String, timestamp: String, ucid: String, gmid: String) {
//        self.oauthToken = oauthToken
//        self.apikey = apikey
//        self.nonce = nonce
//        self.timestamp = timestamp
//        self.ucid = ucid
//        self.gmid = gmid
//    }
//
//    private enum CodingKeys: String, CodingKey {
//        case oauthToken = "oauth_token"
//        case apikey
//        case nonce
//        case timestamp
//        case ucid
//        case gmid
//        case targetEnv
//        case sdk
//        case httpStatusCodes
//        case format
//    }
//
//}

//
//  WebAuthnModels.swift
//  Gigya
//
//  Created by Sagi Shmuel on 17/07/2022.
//  Copyright © 2022 Gigya. All rights reserved.
//

import Foundation

struct WebAuthnGetOptionsResponseModel {
    let options: WebAuthnGetOptionsModel
    
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case options
        case token
    }
    
}

extension WebAuthnGetOptionsResponseModel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let optionsString = try values.decode(String.self, forKey: .options)
        
        let decodedOptions = try DecodeEncodeUtils.decode(fromType: WebAuthnGetOptionsModel.self, data: Data((optionsString).utf8))

        options = decodedOptions
        
        token = try values.decode(String.self, forKey: .token)
    }
}

extension WebAuthnGetOptionsResponseModel: Encodable {}

struct WebAuthnGetOptionsModel: Codable {
    let challenge: String
    let rpId: String
    let userVerification: String?
}

struct WebAuthnInitRegisterResponseModel {
    let options: WebAuthnOptionsModel
    
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case options
        case token
    }
    
}

extension WebAuthnInitRegisterResponseModel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let optionsString = try values.decode(String.self, forKey: .options)
        
        let decodedOptions = try DecodeEncodeUtils.decode(fromType: WebAuthnOptionsModel.self, data: Data((optionsString).utf8))

        options = decodedOptions
        
        token = try values.decode(String.self, forKey: .token)
    }
}

extension WebAuthnInitRegisterResponseModel: Encodable { }

struct WebAuthnOptionsModel: Codable {
    let challenge: String
    let rp: WebAuthnRpModel
    let user: WebAuthnUserModel
    let authenticatorSelection: WebAuthnAuthenticatorSelectionModel
}

struct WebAuthnRpModel: Codable {
    let id: String
    let name: String
}

struct WebAuthnUserModel: Codable {
    let id: String
    let name: String
    let displayName: String
}

struct WebAuthnAuthenticatorSelectionModel: Codable {
    let requireResidentKey: Bool?
    let userVerification: String?
    let authenticatorAttachment: WebAuthnAuthenticatorSelectionType?
}

enum WebAuthnAuthenticatorSelectionType: String, Codable {
    case platform = "platform"
    case crossPlatform = "cross-platform"
    case unspecified = "unspecified"
}

//
//  TFAModel.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 15/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public struct TFAProviderModel: Codable {
    
    public let name: TFAProvider
    public let authLevel: Int?
    
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case authLevel = "authLevel"
    }
    
}

public struct TFAProvidersModel: Codable {
    
    public let activeProviders: [TFAProviderModel]?
    public let inactiveProviders: [TFAProviderModel]?
    
    private enum CodingKeys: String, CodingKey {
        case activeProviders = "activeProviders"
        case inactiveProviders = "inactiveProviders"
    }
}

public struct InitTFAModel: Codable {
    
    public let gigyaAssertion: String?
    
    private enum CodingKeys: String, CodingKey {
        case gigyaAssertion = "gigyaAssertion"
    }
}

public struct TFAVerificationCodeModel: Codable {
    
    public let phvToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case phvToken = "phvToken"
    }
}

public struct TFACompleteVerificationModel: Codable {
    
    public let providerAssertion: String?
    
    private enum CodingKeys: String, CodingKey {
        case providerAssertion = "providerAssertion"
    }
}

public struct TFARegisteredPhone: Codable {
    
    public let id: String?
    public let obfuscated: String?
    public let lastMethod: String?
    public let lastVerification: String?
   
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case obfuscated = "obfuscated"
        case lastMethod = "lastMethod"
        case lastVerification = "lastVerification"
    }
}

public struct TFAGetRegisteredPhoneNumbersModel: Codable {
    
    public let phones: [TFARegisteredPhone]?
    
    private enum CodingKeys: String, CodingKey {
        case phones = "phones"
    }

}

public struct TFAEmail: Codable {
    
    public let id: String?
    public let obfuscated: String?
    public let lastVerification: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case obfuscated = "obfuscated"
        case lastVerification = "lastVerification"
    }
    
}

public struct TFAEmailsModel: Codable {
    
    public let emails: [TFAEmail]?
    
    private enum CodingKeys: String, CodingKey {
        case emails = "emails"
    }
    
}

public struct TFATotpRegisterModel: Codable {

    public let qrCode: String?
    public let sctToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case qrCode = "qrCode"
        case sctToken = "sctToken"
    }
}

public enum TFAMode: String {
    case register
    case verify
}

public enum TFAPhoneMethod: String {
    case sms
    case voice
}

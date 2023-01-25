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
    let cname: String?
    let touchIDText: String?
    let sessionVerificationInterval: Double?
    let account: GigyaAccountConfig?

    private enum CodingKeys: String, CodingKey {
        case apiKey = "GigyaApiKey"
        case apiDomain = "GigyaApiDomain"
        case touchIDText = "GigyaTouchIDMessage"
        case sessionVerificationInterval = "GigyaSessionVerificationInterval"
        case account = "GigyaAccount"
        case cname = "GigyaCname"
    }
    
    func getApiDomain() -> String? {
        if cname != nil {
            return cname
        }
        return apiDomain
    }
}

public struct GigyaAccountConfig: Decodable {
    public var cacheTime: Int?
    public var include: [String]?
    public var extraProfileFields: [String]?

    public init(cacheTime: Int = 0, include: [String] = [], extraProfileFields: [String] = []) {
        self.cacheTime = cacheTime
        self.include = include
        self.extraProfileFields = extraProfileFields
    }
    
    private enum CodingKeys: String, CodingKey {
        case cacheTime
        case include
        case extraProfileFields
    }
}

extension Array where Element == String {
    var withComma: String {
        return self.joined(separator: ",")
    }
}

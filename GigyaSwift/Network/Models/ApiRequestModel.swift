//
//  GigyaApiReguestModel.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 20/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public struct ApiRequestModel {
    public let method: String
    public var params: [String: Any]?
    public let isAnonymous: Bool
    var config: GigyaConfig?

    public init(method: String, params: [String: Any]? = nil, isAnonymous: Bool = false, config: GigyaConfig? = nil) {
        self.method = method
        self.isAnonymous = isAnonymous
        self.config = config
        
        var newParams = params
        newParams?["targetEnv"] = "mobile"

        let timestamp = String(Int(Date().timeIntervalSince1970))
        let nonce = String(timestamp) + "_" + String(describing: arc4random())
        newParams?["nonce"] = nonce

        self.params = newParams

        addRequiredParams()
    }
}

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
    public let params: [String: Any]?
    public let isAnonymous: Bool

    public init(method: String, params: [String: Any]? = nil, isAnonymous: Bool = false) {
        self.method = method
        self.isAnonymous = isAnonymous
        
        var newParams = params
        newParams?["targetEnv"] = "mobile"
        self.params = newParams
    }
}

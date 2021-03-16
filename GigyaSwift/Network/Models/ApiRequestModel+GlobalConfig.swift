//
//  ApiRequestModel+GlobalConfig.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 21/02/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Foundation

extension ApiRequestModel {
    mutating func addRequiredParams() {
        guard let globalParams = config?.accountConfig else {
             return
        }

        var includedParams: [String: String] = [:]

        switch method {
        case GigyaDefinitions.API.getAccountInfo:
            // add include / extra
            includedParams["include"] = globalParams.include?.withComma
            includedParams["extraProfileFields"] = globalParams.extraProfileFields?.withComma

        case GigyaDefinitions.API.verifyLogin,
             GigyaDefinitions.API.register,
             GigyaDefinitions.API.login:
            includedParams["include"] = globalParams.include?.withComma
        default:
            return
        }

        // merge requiredParams
        self.params = self.params?.merging(includedParams) { (current, _) in current }
    }
}

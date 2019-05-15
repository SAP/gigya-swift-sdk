//
//  GigyaApiResultModel.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 20/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public struct GigyaResponseModel: Codable {
    var statusCode: ApiStatusCode
    var errorCode: Int
    var callId: String
    let errorMessage: String?
    internal var requestData: Data? = nil
    
    func toDictionary() -> [String: Any] {
        return DecodeEncodeUtils.dataToDictionary(data: self.requestData)
    }
    
    func asJson() -> String {
        return toDictionary().asJson
    }

    func isInterruptionSupported() -> Bool {
        let errosCodes = Interruption.allCases

        if let interruption = Interruption(rawValue: self.errorCode), errosCodes.contains(interruption) {
            return true
        }
        return false
    }

}

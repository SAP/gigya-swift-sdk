//
//  GigyaApiResultModel.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 20/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public struct GigyaResponseModel: Codable {
    public var statusCode: ApiStatusCode
    public var errorCode: Int
    public var callId: String
    public let errorMessage: String?

    // Mark: - Internal
    let sessionInfo: SessionInfoModel?

    internal var requestData: Data? = nil
    
    public func toDictionary() -> [String: Any] {
        return DecodeEncodeUtils.dataToDictionary(data: self.requestData)
    }
    
    internal func asJson() -> String {
        return toDictionary().asJson
    }

    internal func isInterruptionSupported() -> Bool {
        let errosCodes = Interruption.allCases

        if let interruption = Interruption(rawValue: self.errorCode), errosCodes.contains(interruption) {
            return true
        }
        return false
    }

}

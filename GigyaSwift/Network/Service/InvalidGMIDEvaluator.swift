//
//  InvalidGMIDEvaluator.swift
//  GigyaSwift
//
//  Created by Sagi Shmuel on 24/04/2025.
//  Copyright © 2025 Gigya. All rights reserved.
//

public final class InvalidGMIDEvaluator {
    enum InvalidGMIDError: String {
        case missingCookie = "missing cookie"
        case sessionIsInvalid = "Session is invalid (Missing DeviceId)"
        case missingGCIDOrUCID = "Missing required parameter: gcid or ucid cookie"
    }
    
    let flagsMissingKey: String = "missingKey"
    let errorInvalidParameterValue: Int = 400006
    var retrayCount: Int = 0
    let maxRetries: Int = 2
    
    func evaluate(response: GigyaResponseModel) -> Bool {
        let responseDic = response.toDictionary()
        let errorDetails: String = responseDic["errorDetails"] as? String ?? ""
        
        if let _ = InvalidGMIDError(rawValue: errorDetails) {
            return true
        }
        
        return response.errorCode == errorInvalidParameterValue && response.errorFlags == flagsMissingKey
    }
}

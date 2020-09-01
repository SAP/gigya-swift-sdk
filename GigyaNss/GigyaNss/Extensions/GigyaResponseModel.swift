//
//  GigyaResponseModel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 13/04/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter

extension GigyaResponseModel {
    static func successfullyResponse() -> [String: Any] {
        let resultData = ["errorCode": 0, "errorMessage": "", "callId": "", "statusCode": 200] as [String : Any]

        return resultData
    }

    static func failedResponse(with error: NetworkError) -> FlutterError {
        var code = 500
        var msg = "General error"
        var errorData: String?

        switch error {
        case .gigyaError(data: let data):
            code = data.errorCode
            msg = data.errorMessage ?? ""
            errorData = data.toDictionary().asJson
        case .providerError(data: let data):
            msg = "provider error"
            errorData = data
        case .networkError(error: let error):
            msg = error.localizedDescription
        case .emptyResponse:
            msg = "empty response"
        case .jsonParsingError:
            msg = "json parsing error"
        case .createURLRequestFailed:
            msg = "Request Failed"
        }

        return FlutterError(code: String(code), message: msg, details: errorData)
    }

    static func makeError(errorCode: Int, errorMessage: String) throws -> GigyaResponseModel {
        let error: [String: Any] = ["errorCode": errorCode, "errorMessage": errorMessage, "statusCode": 200, "callId": ""]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: error, options: .prettyPrinted)
            let decodedObject = try JSONDecoder().decode(GigyaResponseModel.self, from: jsonData)
            return decodedObject
        } catch let error {
            throw error
        }

    }
}

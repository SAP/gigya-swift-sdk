//
//  APIServiceError.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 04/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    case gigyaError(data: GigyaResponseModel)
    case providerError(data: String)
    case networkError(Error)
    case dataNotFound // TODO: Need to emptyResponse
    case jsonParsingError(Error)
    case invalidStatusCode(Int)
    case createURLRequestFailed // TODO: need to remove
}

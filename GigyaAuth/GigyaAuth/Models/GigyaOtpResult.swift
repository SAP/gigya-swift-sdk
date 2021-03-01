//
//  GigyaOtpResult.swift
//  GigyaAuth
//
//  Created by Shmuel, Sagi on 10/02/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Gigya

/**
 The `GigyaOtpResult` is an Enum representing a result from login api.
 */
@frozen
public enum GigyaOtpResult<ResponseType: GigyaAccountProtocol> {
    case success(data: ResponseType)

    case pendingOtpVerification(resolver: OtpServiceVerifyProtocol)

    case failure(error: LoginApiError<ResponseType>)
}


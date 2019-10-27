//
//  GigyaApiResult.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 19/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

/**
The `GigyaApiResult` is an Enum representing a network response.
 */
public enum GigyaApiResult<ResponseType> {
    case success(data: ResponseType)

    case failure(_ error: NetworkError)
}

/**
 The `GigyaLoginResult` is an Enum representing a result from login api.
 */
public enum GigyaLoginResult<ResponseType: GigyaAccountProtocol> {
    case success(data: ResponseType)

    case failure(LoginApiError<ResponseType>)
}

public struct LoginApiError<T: GigyaAccountProtocol> {
    public let error: NetworkError

    public let interruption: GigyaInterruptions<T>?
}

/**
 The `GigyaInterruptions` is an Enum representing account interruptions handling.
 */
public enum GigyaInterruptions<T: GigyaAccountProtocol> {
    case pendingRegistration(resolver: PendingRegistrationResolver<T>)

    case pendingVerification(regToken: String)

    case pendingPasswordChange(regToken: String)

    case conflitingAccount(resolver: LinkAccountsResolver<T>)

    case pendingTwoFactorRegistration(response: GigyaResponseModel, inactiveProviders: [TFAProviderModel]?, factory: TFAResolverFactory<T>)

    case pendingTwoFactorVerification(response: GigyaResponseModel, activeProviders: [TFAProviderModel]?, factory: TFAResolverFactory<T>)
}

/**
 The `GigyaBiometricResult` is an Enum representing a biometric result.
 */
public enum GigyaBiometricResult {
    case success

    case failure
}

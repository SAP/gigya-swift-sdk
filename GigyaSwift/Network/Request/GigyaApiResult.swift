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
@frozen
public enum GigyaApiResult<ResponseType> {
    case success(data: ResponseType)

    case failure(_ error: NetworkError)
}

/**
 The `LoginApiError` is an Struct representing a result from login api with option to resolving interruptions.
 */
public struct LoginApiError<T: GigyaAccountProtocol> {
    public let error: NetworkError

    public let interruption: GigyaInterruptions<T>?

    public init(error: NetworkError, interruption: GigyaInterruptions<T>? = nil) {
        self.error = error
        self.interruption = interruption
    }
}

/**
 The `GigyaLoginResult` is an Enum representing a result from login api.
 */
@frozen
public enum GigyaLoginResult<ResponseType: GigyaAccountProtocol> {
    case success(data: ResponseType)

    case failure(LoginApiError<ResponseType>)
}

/**
 The `GigyaInterruptions` is an Enum representing account interruptions handling.
 */
@frozen
public enum GigyaInterruptions<T: GigyaAccountProtocol> {
    /**
    Pending Registration interruption.

     - Parameter resolver: is a factory of `PendingRegistrationResolver`
    */

    case pendingRegistration(resolver: PendingRegistrationResolver<T>)

    /**
    Pending Verification interruption.

     - Parameter regToken: Registration token required for resolving the interruption.
    */

    case pendingVerification(regToken: String)

    /**
    Pending Password Change interruption.

     - Parameter regToken: Registration token required for resolving the interruption.
    */

    case pendingPasswordChange(regToken: String)


    /**
    Confliting Account interruption.

     - Parameter resolver: is a factory of `LinkAccountsResolver`
    */
    case conflitingAccount(resolver: LinkAccountsResolver<T>)

    case pendingTwoFactorRegistration(response: GigyaResponseModel, inactiveProviders: [TFAProviderModel]?, factory: TFAResolverFactory<T>)

    case pendingTwoFactorVerification(response: GigyaResponseModel, activeProviders: [TFAProviderModel]?, factory: TFAResolverFactory<T>)
}

/**
 The `GigyaBiometricResult` is an Enum representing a biometric result.
 */
@frozen
public enum GigyaBiometricResult {
    case success

    case failure
}

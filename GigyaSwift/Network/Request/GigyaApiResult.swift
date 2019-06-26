//
//  GigyaApiResult.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 19/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public enum GigyaApiResult<Response> {
    case success(data: Response)
    case failure(_ error: NetworkError)
}

public enum GigyaLoginResult<Response: GigyaAccountProtocol> {
    case success(data: Response)
    case failure(LoginApiError<Response>)
}

public struct LoginApiError<T: GigyaAccountProtocol> {
    public let error: NetworkError
    public let interruption: GigyaInterruptions<T>?
}

public enum GigyaInterruptions<T: GigyaAccountProtocol> {
    case pendingRegistration(resolver: PendingRegistrationResolver<T>)
    case pendingVerification(regToken: String)
    case pendingPasswordChange(regToken: String)
    case conflitingAccount(resolver: LinkAccountsResolver<T>)
    case pendingTwoFactorRegistration(response: GigyaResponseModel, inactiveProviders: [TFAProviderModel]?, factory: TFAResolverFactory<T>)
    case pendingTwoFactorVerification(response: GigyaResponseModel, activeProviders: [TFAProviderModel]?, factory: TFAResolverFactory<T>)
}

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
    case failure(NetworkError)
}

public enum GigyaLoginResult<Response: Codable> {
    case success(data: Response)
    case failure(LoginApiError<Response>)
}

public struct LoginApiError<T: Codable> {
    public let error: NetworkError
    public let interruption: GigyaInterruptions<T>?
}

public enum GigyaInterruptions<T: Codable> {
    case pendingRegistration(regToken: String)
    case pendingVerification(regToken: String)
    case conflitingAccounts(resolver: LinkAccountsResolver<T>)
    case pendingTwoFactorRegistration(resolver: TFARegistrationResolverProtocol)
    case pendingTwoFactorVerification(resolver: TFAVerificationResolverProtocol)
    case onPhoneVerificationCodeSent
    case onRegisteredPhoneNumbers(numbers: [TFARegisteredPhone])
    case onRegisteredEmails(emails: [TFAEmail])
    case onEmailVerificationCodeSent
    case onTotpQRCode(qrCode: String)
}

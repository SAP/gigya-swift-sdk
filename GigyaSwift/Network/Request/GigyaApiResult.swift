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
    case pendingPasswordChange(regToken: String)
    case conflitingAccount(resolver: LinkAccountsResolver<T>)
    case pendingTwoFactorRegistration(resolver: Any)
    case pendingTwoFactorVerification(resolver: Any)
//    case onPhoneVerificationCodeSent
//    case onRegisteredPhoneNumbers(numbers: [TFARegisteredPhone])
//    case onRegisteredEmails(emails: [TFAEmail])
//    case onEmailVerificationCodeSent
//    case onTotpQRCode(qrCode: UIImage?)
}

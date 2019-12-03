//
//  InterruptionResolverFactory.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 23/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

final class InterruptionResolverFactory: InterruptionResolverFactoryProtocol {
    var resolver: BaseResolver?

    private var enabled: Bool = true

    var isEnabled: Bool {
        return enabled
    }

    func setEnabled(_ sdkHandles: Bool) {
        enabled = sdkHandles
    }

    func resolve<T: GigyaAccountProtocol>(error: NetworkError, businessDelegate: BusinessApiDelegate, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        switch error {
        case .gigyaError(let data):
            // check if interruption supported
            if data.isInterruptionSupported() {
                GigyaLogger.log(with: self, message: "[interruptionResolver] - interruption supported: \(data)")

                // get interruption by error code
                guard let errorCode: Interruption = Interruption(rawValue: data.errorCode) else { return }

                // get all data from request
                let dataResponse = data.toDictionary()

                guard let regToken = dataResponse["regToken"] as? String else {
                    GigyaLogger.log(with: self, message: "[interruptionResolver] - regToken not exists")

                    forwordFailed(error: error, completion: completion)
                    return
                }

                switch errorCode {
                case .pendingRegistration:
                    // pending registration
                    resolver = PendingRegistrationResolver(originalError: error, regToken: regToken, businessDelegate: businessDelegate, completion: completion)
                    resolver?.start?()
                case .pendingVerification:
                    // pending veryfication
                    let loginError = LoginApiError<T>(error: error, interruption: .pendingVerification(regToken: regToken))
                    completion(.failure(loginError))
                case .conflitingAccounts:
                    // conflicting accounts
                    resolver = LinkAccountsResolver(originalError: error, regToken: regToken, businessDelegate: businessDelegate, completion: completion)
                    resolver?.start?()
                case .accountLinked:
                    // account successfuly linked
                    businessDelegate.callfinalizeRegistration(regToken: regToken, completion: completion)
                case .pendingTwoFactorRegistration, .pendingTwoFactorVerification:
                    // pending TFA registration / verification
                    resolver = TFAProviderResolver(businessApiDelegate: businessDelegate, interruption: data, completionHandler: completion)
                    resolver?.start?()
                case .pendingPasswordChange:
                    let loginError = LoginApiError<T>(error: error, interruption: .pendingPasswordChange(regToken: regToken))
                    completion(.failure(loginError))
                }
            } else {
                GigyaLogger.log(with: self, message: "[interruptionResolver] - interruption not supported")

                forwordFailed(error: error, completion: completion)
            }
        default:
            // When the error is not an intteruption, it's should return the original error to the client.
            GigyaLogger.log(with: self, message: "[interruptionResolver] - error: \(error)")

            forwordFailed(error: error, completion: completion)
        }
    }

    private func forwordFailed<T: Codable>(error: NetworkError, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        let loginError = LoginApiError<T>(error: error, interruption: nil)
        completion(.failure(loginError))
    }
}

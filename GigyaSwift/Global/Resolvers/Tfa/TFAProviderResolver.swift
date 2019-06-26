//
//  TFAProviderResolver.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 23/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class TFAProviderResolver<T: GigyaAccountProtocol>: Resolver<T>, BaseResolver {

    required init(businessApiDelegate: BusinessApiDelegate, interruption: GigyaResponseModel, completionHandler: @escaping (GigyaLoginResult<T>) -> Void) {
        super.init(businessApiDelegate: businessApiDelegate, interruption: interruption, completionHandler: completionHandler)
    }

    func start() {
        let params = ["regToken": self.regToken]

        businessApiDelegate.sendApi(dataType: TFAProvidersModel.self,  api: GigyaDefinitions.API.tfaGetProviders, params: params) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                // Evaluate available providers.
                let activeProviders = data.activeProviders
                let inactiveProviders = data.inactiveProviders

                guard let interruptionError: Interruption = Interruption(rawValue: self.interruption.errorCode) else { return }

                var errorInterruption: LoginApiError<T>?

                let tfaResolverFactory = TFAResolverFactory(businessApiDelegate: self.businessApiDelegate, interruption: self.interruption, completionHandler: self.completionHandler)

                switch interruptionError {
                case .pendingTwoFactorRegistration:
                    errorInterruption = LoginApiError<T>(error: .gigyaError(data: self.interruption), interruption: .pendingTwoFactorRegistration(response: self.interruption, inactiveProviders: inactiveProviders, factory: tfaResolverFactory))

                case .pendingTwoFactorVerification:
                    errorInterruption = LoginApiError<T>(error: .gigyaError(data: self.interruption), interruption: .pendingTwoFactorVerification(response: self.interruption, activeProviders: activeProviders, factory: tfaResolverFactory))

                default:
                    errorInterruption = LoginApiError<T>(error: .gigyaError(data: self.interruption), interruption: nil)
                }

                if let errorInterruption = errorInterruption {
                    self.completionHandler(.failure(errorInterruption))
                }

            case .failure(let error):
                let errorInterruption = LoginApiError<T>(error: error, interruption: nil)
                self.completionHandler(.failure(errorInterruption))
            }
        }
    }
}

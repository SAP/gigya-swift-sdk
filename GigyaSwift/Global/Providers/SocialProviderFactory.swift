//
//  ProviderFactory.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 18/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol IOCSocialProviderFactoryProtocol {
    func getProvider(with socialProvider: GigyaSocielProviders, delegate: BusinessApiDelegate) -> Provider
}

class SocialProviderFactory: IOCSocialProviderFactoryProtocol {
    let config: GigyaConfig

    let sessionService: IOCSessionServiceProtocol

    init(sessionService: IOCSessionServiceProtocol, config: GigyaConfig) {
        self.sessionService = sessionService
        self.config = config
    }

    func getProvider(with socialProvider: GigyaSocielProviders, delegate: BusinessApiDelegate) -> Provider {
        switch socialProvider {
        case .facebook:
            if FacebookProvider.isAvailable() {
                return FacebookProvider(provider: FacebookWrapper(), delegate: delegate)
            }
        case .google:
            if GoogleProvider.isAvailable() {
                return GoogleProvider(provider: GoogleWrapper(), delegate: delegate)
            }
        default:
            break
        }

        return WebLoginProvider(sessionService: sessionService, provider: WebLoginWrapper(config: config, providerType: socialProvider), delegate: delegate)
    }
}

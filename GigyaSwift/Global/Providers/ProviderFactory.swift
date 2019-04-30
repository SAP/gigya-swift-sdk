//
//  ProviderFactory.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 18/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol IOCProviderFactoryProtocol {
    func getProvider(with socialProvider: GigyaSocielProviders, delegate: BusinessApiDelegate) -> Provider
}

class ProviderFactory: IOCProviderFactoryProtocol {
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

        return WebViewProvider(sessionService: sessionService, provider: WebViewWrapper(config: config, providerType: socialProvider), delegate: delegate)
    }
}

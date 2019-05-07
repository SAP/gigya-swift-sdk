//
//  ProviderFactoryMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import GigyaSwift

class ProviderFactoryMock: IOCSocialProvidersManagerProtocol {
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
                return FacebookProviderMock(provider: FacebookWrapperMock(), delegate: delegate)
            }
        case .google:
            if GoogleProvider.isAvailable() {
                return GoogleProviderMock(provider: GoogleWrapperMock(), delegate: delegate)
            }
        default:
            break
        }

        return WebLoginProvider(sessionService: sessionService, provider: WebLoginWrapper(config: config, providerType: socialProvider), delegate: delegate)
    }
}

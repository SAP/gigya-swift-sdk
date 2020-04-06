//
//  ProviderFactoryMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import Gigya

class ProviderFactoryMock: SocialProvidersManagerProtocol {

    let config: GigyaConfig
    let sessionService: SessionServiceProtocol

    init(sessionService: SessionServiceProtocol, config: GigyaConfig) {
        self.sessionService = sessionService
        self.config = config
    }

    func getProvider(with socialProvider: GigyaSocialProviders, delegate: BusinessApiDelegate) -> Provider {
        switch socialProvider {
        case .facebook, .google:
            return SocialProviderMock(providerType: .google, provider: SocialProviderWrapperMock(), delegate: delegate)

        default:
            break
        }

        return WebLoginProvider(sessionService: sessionService, provider: WebProviderWrapperMock(), delegate: delegate)
    }

    func registerProvider(by provider: GigyaNativeSocialProviders, factory: ProviderWrapperProtocol) {

    }
}

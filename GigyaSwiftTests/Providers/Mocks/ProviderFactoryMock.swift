//
//  ProviderFactoryMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import GigyaSwift

class ProviderFactoryMock: IOCProviderFactoryProtocol {
    let config: GigyaConfig

    init(config: GigyaConfig) {
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
        case .yahoo:
            return WebViewProvider(provider: WebViewWrapper(config: config, providerType: socialProvider), delegate: delegate)
        case .web:
            return WebViewProvider(provider: WebViewWrapper(config: config, providerType: socialProvider), delegate: delegate)
        }

        return WebViewProvider(provider: WebViewWrapper(config: config, providerType: socialProvider), delegate: delegate) // TODO: Need to return web provider
    }
}

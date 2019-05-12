//
//  ProviderFactory.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 18/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol IOCSocialProvidersManagerProtocol {
    func getProvider(with socialProvider: GigyaSocielProviders, delegate: BusinessApiDelegate) -> Provider
}

class SocialProvidersManager: IOCSocialProvidersManagerProtocol {
    let config: GigyaConfig

    let sessionService: IOCSessionServiceProtocol

    private var providersContainer: [GigyaNativeSocielProviders: ProviderWrapperProtocol] = [:]

    init(sessionService: IOCSessionServiceProtocol, config: GigyaConfig) {
        self.sessionService = sessionService
        self.config = config
        
        checkIncludedProviders()
    }

    func checkIncludedProviders() {
        for provider in GigyaNativeSocielProviders.allCases {
            if let providerWrapperClass = NSClassFromString("\(Bundle.appName()).\(provider.getClassName())") {
                guard let providerWrapper = providerWrapperClass as AnyClass as? ProviderWrapperProtocol.Type else {
                    GigyaLogger.error(message: "\(providerWrapperClass.description()) not extend to ProviderWrapperProtocol")
                }

                providersContainer[provider] = providerWrapper.init()
            }
        }
    }

    func getProvider(with socialProvider: GigyaSocielProviders, delegate: BusinessApiDelegate) -> Provider {
        if let providerType: GigyaNativeSocielProviders = GigyaNativeSocielProviders(rawValue: socialProvider.rawValue) {
            guard let wrapper = providersContainer[providerType] else { GigyaLogger.error(message: "\(providerType.description) provider not found") }
            return SocialLoginProvider(providerType: socialProvider, provider: wrapper, delegate: delegate)
        }

        if socialProvider == .facebook || socialProvider == .wechat {
            GigyaLogger.error(message: "[\(socialProvider.rawValue)] can't login with WebView, install related sdk.")
        }

        return WebLoginProvider(sessionService: sessionService, provider: WebLoginWrapper(config: config, providerType: socialProvider), delegate: delegate)
    }
}

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
                    GigyaLogger.error(message: "\(provider.getClassName()) not extend to ProviderWrapperProtocol")
                }

                providersContainer[provider] = providerWrapper.init()

                GigyaLogger.log(with: self, message: "[\(provider.rawValue)] save factory")
            }
        }
    }

    func getProvider(with socialProvider: GigyaSocielProviders, delegate: BusinessApiDelegate) -> Provider {
        if let providerType: GigyaNativeSocielProviders = GigyaNativeSocielProviders(rawValue: socialProvider.rawValue) {
            if let wrapper = providersContainer[providerType] {
                GigyaLogger.log(with: self, message: "[\(socialProvider.rawValue)] - use sdk")

                return SocialLoginProvider(providerType: socialProvider, provider: wrapper, delegate: delegate)
            } else {
                if socialProvider == .facebook || socialProvider == .wechat {
                    GigyaLogger.error(message: "[\(socialProvider.rawValue)] can't login with WebView, install related sdk.")
                }
            }
        }

        GigyaLogger.log(with: self, message: "[\(socialProvider.rawValue)] - use webview")

        return WebLoginProvider(sessionService: sessionService, provider: WebLoginWrapper(config: config, providerType: socialProvider), delegate: delegate)
    }
}

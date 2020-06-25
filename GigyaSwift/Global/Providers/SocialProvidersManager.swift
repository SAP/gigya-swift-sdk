//
//  ProviderFactory.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 18/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol SocialProvidersManagerProtocol {
    func getProvider(with socialProvider: GigyaSocialProviders, delegate: BusinessApiDelegate) -> Provider

    func registerProvider(by provider: GigyaNativeSocialProviders, wrapper: ProviderWrapperProtocol)
}

final class SocialProvidersManager: SocialProvidersManagerProtocol {
    let config: GigyaConfig

    let sessionService: SessionServiceProtocol

    let persistenceService: PersistenceService

    private var networkAdapter: NetworkAdapterProtocol

    private var providersContainer: [GigyaNativeSocialProviders: ProviderWrapperProtocol] = [:]

    init(sessionService: SessionServiceProtocol, config: GigyaConfig, persistenceService: PersistenceService, networkAdapter: NetworkAdapterProtocol) {
        self.sessionService = sessionService
        self.config = config
        self.persistenceService = persistenceService
        self.networkAdapter = networkAdapter
        
        checkIncludedProviders()
    }

    func checkIncludedProviders() {
        for provider in GigyaNativeSocialProviders.allCases {
            if let providerWrapperClass = NSClassFromString("\(Bundle.appName()).\(provider.getClassName())") {
                guard let providerWrapper = providerWrapperClass as AnyClass as? ProviderWrapperProtocol.Type else {
                    GigyaLogger.error(message: "\(provider.getClassName()) not extend to ProviderWrapperProtocol")
                }

                providersContainer[provider] = providerWrapper.init()

                GigyaLogger.log(with: self, message: "[\(provider.rawValue)] save factory")
            }
        }
    }

    func getProvider(with socialProvider: GigyaSocialProviders, delegate: BusinessApiDelegate) -> Provider {
        if let providerType: GigyaNativeSocialProviders = GigyaNativeSocialProviders(rawValue: socialProvider.rawValue) {
            if let wrapper = providersContainer[providerType] {
                GigyaLogger.log(with: self, message: "[\(socialProvider.rawValue)] - use sdk")

                return SocialLoginProvider(providerType: socialProvider, provider: wrapper, delegate: delegate)
            }
        }

        if socialProvider.isRequiredSdk() {
            GigyaLogger.error(message: "[\(socialProvider.rawValue)] can't login with WebView, install related sdk.")
        }

        GigyaLogger.log(with: self, message: "[\(socialProvider.rawValue)] - use webview")

        return WebLoginProvider(sessionService: sessionService, provider: WebLoginWrapper(config: config, persistenceService: persistenceService, providerType: socialProvider, networkAdapter: networkAdapter), delegate: delegate)
    }

    func registerProvider(by provider: GigyaNativeSocialProviders, wrapper: ProviderWrapperProtocol) {
        providersContainer[provider] = wrapper
    }
}

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
    func getProvider(with socialProvider: GigyaSocielProviders, delegate: BusinessApiDelegate) -> Provider {
        switch socialProvider {
        case .facebook:
            return FacebookProvider(provider: FacebookWrapper(), delegate: delegate)
        case .google:
            if GoogleProvider.isAvailable() {
                return GoogleProvider(provider: GoogleWrapper(), delegate: delegate)
            }
        case .web:
            return WebViewProvider(provider: WebViewWrapper(), delegate: delegate)
        }

        return GoogleProvider(provider: GoogleWrapper(), delegate: delegate) // TODO: Need to return web provider
    }
}

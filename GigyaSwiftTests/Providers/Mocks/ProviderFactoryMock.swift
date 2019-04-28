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
    func getProvider(with socialProvider: GigyaSocielProviders, delegate: BusinessApiDelegate) -> Provider {
        switch socialProvider {
        case .facebook:
            return FacebookProvider(provider: FacebookWrapper(), delegate: delegate)
        case .google:
            if GoogleProvider.isAvailable() {
                return GoogleProviderMock(provider: GoogleWrapperMock(), delegate: delegate)
            }
        case .web:
            return WebViewProvider(provider: WebViewWrapper(), delegate: delegate)
        }

        return WebViewProvider(provider: WebViewWrapper(), delegate: delegate) // TODO: Need to return web provider
    }
}

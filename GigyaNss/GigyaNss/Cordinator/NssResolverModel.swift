//
//  NssResolverWrapper.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 30/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya

protocol NssResolverModelProtocol { }

final class NssResolverModel<T>: NssResolverModelProtocol {
    let interrupt: NssInterruptionsSupported

    var regToken: String?

    var resolver: T?

    var tfaProviders: [TFAProviderModel]?

    init(interrupt: NssInterruptionsSupported, regToken: String) {
        self.interrupt = interrupt
        self.regToken = regToken
    }

    init(interrupt: NssInterruptionsSupported, resolver: T) {
        self.interrupt = interrupt
        self.resolver = resolver
    }

    init(interrupt: NssInterruptionsSupported, resolverFactory: T, tfaProviders: [TFAProviderModel]) {
        self.interrupt = interrupt
        self.resolver = resolverFactory
        self.tfaProviders = tfaProviders
    }
}

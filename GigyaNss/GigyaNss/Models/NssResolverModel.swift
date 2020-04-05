//
//  NssResolverWrapper.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 30/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya

protocol NssResolverModelProtocol {
    var interrupt: NssInterruptionsSupported { get }
}

// split it to per class for resolver type
final class NssResolverModel<T>: NssResolverModelProtocol {
    let interrupt: NssInterruptionsSupported

    var resolver: T?

    init(interrupt: NssInterruptionsSupported, resolver: T) {
        self.interrupt = interrupt
        self.resolver = resolver
    }
}

final class NssResolverRegTokenModel<T>: NssResolverModelProtocol {
    let interrupt: NssInterruptionsSupported

    var regToken: String?

    // type 1
    init(interrupt: NssInterruptionsSupported, regToken: String) {
        self.interrupt = interrupt
        self.regToken = regToken
    }
}

final class NssResolverTfaModel<T>: NssResolverModelProtocol {
    let interrupt: NssInterruptionsSupported

    var resolver: T?

    var tfaProviders: [TFAProviderModel]?

    init(interrupt: NssInterruptionsSupported, resolverFactory: T, tfaProviders: [TFAProviderModel]) {
        self.interrupt = interrupt
        self.resolver = resolverFactory
        self.tfaProviders = tfaProviders
    }
}

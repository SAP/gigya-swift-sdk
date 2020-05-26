//
//  NssResolverTfaModel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 02/04/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya

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

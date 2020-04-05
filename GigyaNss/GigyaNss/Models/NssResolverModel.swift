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

final class NssResolverModel<T>: NssResolverModelProtocol {
    let interrupt: NssInterruptionsSupported

    var resolver: T?

    init(interrupt: NssInterruptionsSupported, resolver: T) {
        self.interrupt = interrupt
        self.resolver = resolver
    }
}

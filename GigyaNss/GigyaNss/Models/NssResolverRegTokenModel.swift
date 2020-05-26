//
//  NssResolverRegTokenModel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 02/04/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation

final class NssResolverRegTokenModel<T>: NssResolverModelProtocol {
    let interrupt: NssInterruptionsSupported

    var regToken: String?

    // type 1
    init(interrupt: NssInterruptionsSupported, regToken: String) {
        self.interrupt = interrupt
        self.regToken = regToken
    }
}

//
//  TFAResolverFactory.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 23/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public class TFAResolverFactory<A: GigyaAccountProtocol> {
    let businessApiDelegate: BusinessApiDelegate
    let interruption: GigyaResponseModel
    let completionHandler: (GigyaLoginResult<A>) -> Void

    init(businessApiDelegate: BusinessApiDelegate, interruption: GigyaResponseModel, completionHandler: @escaping (GigyaLoginResult<A>) -> Void) {
        self.businessApiDelegate = businessApiDelegate
        self.interruption = interruption
        self.completionHandler = completionHandler
    }

    public func getResolver<T: TFAResolver<A>>(for resolver: T.Type) -> T {

        let resolverA = T.init(businessApiDelegate: businessApiDelegate, interruption: interruption, completionHandler: completionHandler)

        return resolverA

    }
}

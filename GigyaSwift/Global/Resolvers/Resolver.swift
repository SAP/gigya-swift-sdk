//
//  Resolver.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 23/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

open class Resolver<T: GigyaAccountProtocol> {

    internal let businessApiDelegate: BusinessApiDelegate
    internal let interruption: GigyaResponseModel
    internal let completionHandler: (GigyaLoginResult<T>) -> Void

    public var regToken: String {
        // get all data from request
        let dataIntteruption = interruption.toDictionary()
        return dataIntteruption["regToken"] as? String ?? ""
    }

    public required init(businessApiDelegate: BusinessApiDelegate, interruption: GigyaResponseModel, completionHandler: @escaping (GigyaLoginResult<T>) -> Void) {
        self.businessApiDelegate = businessApiDelegate
        self.interruption = interruption
        self.completionHandler = completionHandler
    }
}

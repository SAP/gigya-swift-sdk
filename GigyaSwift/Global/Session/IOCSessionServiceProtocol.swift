//
//  IOCSessionServiceProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol IOCSessionServiceProtocol {

    var accountService: IOCAccountServiceProtocol { get }

    var session: GigyaSession? { get set }

    init(config: GigyaConfig, accountService: IOCAccountServiceProtocol)

    func isValidSession() -> Bool

    func setSession(_ model: SessionInfoModel?)
    
    func getSession()

    func clear()

}

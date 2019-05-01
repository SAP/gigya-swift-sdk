//
//  IOCSessionServiceProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol IOCSessionServiceProtocol {
    var gigyaApi: IOCGigyaWrapperProtocol { get }

    var accountService: IOCAccountServiceProtocol { get }

    var session: GigyaSession? { get set }

    init(gigyaApi: IOCGigyaWrapperProtocol, accountService: IOCAccountServiceProtocol)

    func isValidSession() -> Bool

    func setSession(_ session: GigyaSession)

    func getSession(result: @escaping (GigyaSession?) -> Void)

    func clear()

}

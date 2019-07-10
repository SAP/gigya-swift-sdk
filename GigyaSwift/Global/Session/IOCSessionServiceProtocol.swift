//
//  IOCSessionServiceProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public protocol IOCSessionServiceProtocol {

    var accountService: IOCAccountServiceProtocol { get }

    var session: GigyaSession? { get set }

    init(config: GigyaConfig, accountService: IOCAccountServiceProtocol)

    func isValidSession() -> Bool

    func setSession(_ model: SessionInfoModel?)

    func getSession(biometric: Bool, completion: @escaping ((Bool) -> Void))

    func setSessionAs(biometric: Bool, completion: @escaping (GigyaBiometricResult) -> Void)

    func clear()

    func clearSession()

}

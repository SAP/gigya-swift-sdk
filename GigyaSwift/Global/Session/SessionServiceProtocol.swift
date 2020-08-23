//
//  IOCSessionServiceProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public protocol SessionServiceProtocol {

    var session: GigyaSession? { get set }

    func isValidSession() -> Bool

    func setSession(_ model: SessionInfoModel?)

    func getSession(completion: @escaping ((Bool) -> Void))

    func setSessionAs(biometric: Bool, completion: @escaping (GigyaBiometricResult) -> Void)

    var handlersAfterSetSession: InterceptorsUtils { get }

    func clear()

    func clear(completion: @escaping () -> Void)

    func clearSession()

    func setClearCookies(to value: Bool)

}

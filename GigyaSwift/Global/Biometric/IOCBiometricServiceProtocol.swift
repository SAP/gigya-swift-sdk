//
//  IOCBiometricServiceProtocol.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 08/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public protocol BiometricServiceProtocol {

    var isLocked: Bool { get }

    var isOptIn: Bool { get }

    func optIn(completion: @escaping (GigyaBiometricResult) -> Void)

    func optOut(completion: @escaping (GigyaBiometricResult) -> Void)

    func unlockSession(completion: @escaping (GigyaBiometricResult) -> Void)

    func lockSession(completion: @escaping (GigyaBiometricResult) -> Void)
    
}

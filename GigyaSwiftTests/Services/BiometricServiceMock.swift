//
//  BiometricServiceMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 25/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
@testable import Gigya

class BiometricServiceMock: BiometricServiceProtocol {
    var isLocked: Bool = false

    var isOptIn: Bool = false

    func optIn(completion: @escaping (GigyaBiometricResult) -> Void) {
        completion(.success)
    }

    func optOut(completion: @escaping (GigyaBiometricResult) -> Void) {
        completion(.success)
    }

    func unlockSession(completion: @escaping (GigyaBiometricResult) -> Void) {
        completion(.success)
    }

    func lockSession(completion: @escaping (GigyaBiometricResult) -> Void) {
        completion(.success)
    }

    func setOptIn() {
        isOptIn = true
    }

    func setOptOut() {
        isOptIn = false
    }

}

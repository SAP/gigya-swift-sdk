//
//  IOCBiometricServiceProtocol.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 08/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

/**
 The `BiometricService` is an interface for implementing FaceID/TouchID to secure your Gigya session.
 */
public protocol BiometricServiceProtocol {

    /**
     Returns the indication if the session is locked.
     */
    var isLocked: Bool { get }

    /**
     Returns the indication if the session was opted-in.
     */
    var isOptIn: Bool { get }

    /**
     Opt-in operation.
     Encrypt session with your biometric method.

     - Parameter completion:  Response GigyaApiResult<T>.
     */
    func optIn(completion: @escaping (GigyaBiometricResult) -> Void)

    /**
     Opt-out operation.
     Decrypt session with your biometric method.

     - Parameter completion:  Response GigyaApiResult<T>.
     */
    func optOut(completion: @escaping (GigyaBiometricResult) -> Void)

    /**
     Unlock operation.
     Decrypt session and save as default.

     - Parameter completion:  Response GigyaBiometricResult.
     */
    func unlockSession(completion: @escaping (GigyaBiometricResult) -> Void)

    /**
     Lock operation
     Clear current heap session. Does not require biometric authentication.

     - Parameter completion:  Response GigyaBiometricResult.
     */
    func lockSession(completion: @escaping (GigyaBiometricResult) -> Void)
    
}

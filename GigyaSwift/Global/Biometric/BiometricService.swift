//
//  BiometricService.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 08/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class BiometricService: BiometricServiceProtocol, BiometricServiceInternalProtocol {

    let config: GigyaConfig

    let persistenceService: PersistenceService

    let sessionService: SessionServiceProtocol

    /**
     Returns the indication if the session was opted-in.
     */

    var isOptIn: Bool {
        return persistenceService.biometricAllow ?? false
    }

    /**
     Returns the indication if the session is locked.
     */

    var isLocked: Bool {
        return persistenceService.biometricLocked ?? false
    }

    init(config: GigyaConfig, persistenceService: PersistenceService, sessionService: SessionServiceProtocol) {
        self.sessionService = sessionService
        self.config = config
        self.persistenceService = persistenceService
    }

    // MARK: - Biometric

    /**
     Opt-in operation.
     Encrypt session with your biometric method.

     - Parameter completion:  Response GigyaApiResult<T>.
     */
    public func optIn(completion: @escaping (GigyaBiometricResult) -> Void) {
        sessionService.setSessionAs(biometric: true) { [weak self] (result) in
            switch result {
            case .success:
                self?.persistenceService.setBiometricEnable(to: true)

                completion(.success)
            case .failure:
                completion(.failure)
            }
        }
    }

    /**
     Opt-out operation.
     Decrypt session with your biometric method.

     - Parameter completion:  Response GigyaApiResult<T>.
     */
    public func optOut(completion: @escaping (GigyaBiometricResult) -> Void) {
        sessionService.setSessionAs(biometric: false) { [weak self] (result) in
            switch result {
            case .success:
                self?.persistenceService.setBiometricEnable(to: false)

                completion(.success)
            case .failure:
                completion(.failure)
            }
        }
    }

    /**
     Unlock operation.
     Decrypt session and save as default.

     - Parameter completion:  Response GigyaBiometricResult.
     */
    public func unlockSession(completion: @escaping (GigyaBiometricResult) -> Void) {
        guard persistenceService.biometricAllow == true else {
            GigyaLogger.log(with: "biometric", message: "can't load session because user don't opt in")
            completion(.failure)
            return
        }

        sessionService.getSession(skipLoadSession: false) { [weak self] (success) in
            if success == true {
                completion(.success)
            } else {
                completion(.failure)
            }

            self?.sessionService.revokeSemphore()
        }
    }

    /**
     Lock operation
     Clear current heap session. Does not require biometric authentication.

     - Parameter completion:  Response GigyaBiometricResult.
     */
    public func lockSession(completion: @escaping (GigyaBiometricResult) -> Void) {
        if isOptIn {
            sessionService.clearSession()
            persistenceService.setBiometricLocked(to: true)
            completion(.success)
        } else {
            GigyaLogger.log(with: "biometric", message: "can't lock session because user don't opt in")

            completion(.failure)
        }
    }

    // Mark: - Internal functions

    internal func clearBiometric() {
        persistenceService.setBiometricEnable(to: false)
        persistenceService.setBiometricLocked(to: false)
    }
}

//
//  BiometricService.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 08/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

final class BiometricService: BiometricServiceProtocol, BiometricServiceInternalProtocol {

    let config: GigyaConfig

    let persistenceService: PersistenceService

    let sessionService: SessionServiceProtocol

    /**
     Returns the indication if the session was opted-in.
     */

    var isOptIn: Bool {
        return persistenceService.biometricAllow
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

                main { completion(.success) }
            case .failure:
                main {  completion(.failure) }
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
                self?.persistenceService.setBiometricLocked(to: false)

                main { completion(.success) }
            case .failure:
                main { completion(.failure) }
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
            main { completion(.failure) }
            return
        }

        sessionService.getSession() { (success) in
            if success == true {
                main { completion(.success) }
            } else {
                main { completion(.failure) }
            }
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
            main { completion(.success) }
        } else {
            GigyaLogger.log(with: "biometric", message: "can't lock session because user don't opt in")

            main { completion(.failure) }
        }
    }

    // Mark: - Internal functions

    internal func clearBiometric() {
        persistenceService.setBiometricEnable(to: false)
        persistenceService.setBiometricLocked(to: false)
    }
}

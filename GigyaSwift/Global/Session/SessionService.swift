//
//  SessionManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class SessionService: SessionServiceProtocol {

    var accountService: AccountServiceProtocol

    let keychainHelper: KeychainStorageFactory

    var session: GigyaSession?

    let config: GigyaConfig

    let persistenceService: PersistenceService

    private var sessionLoad: Bool = false

    private let semaphore = DispatchSemaphore(value: 0)

    init(config: GigyaConfig, persistenceService: PersistenceService, accountService: AccountServiceProtocol, keychainHelper: KeychainStorageFactory) {
        self.accountService = accountService
        self.keychainHelper = keychainHelper
        self.config = config
        self.persistenceService = persistenceService

        checkFirstRun()

        if persistenceService.biometricAllow == false {
            getSession() { [weak self] success in
                GigyaLogger.log(with: self, message: "[SessionService.getFromInit]: is success: - \(success)")
            }
        }
    }

    func checkFirstRun() {
        let hasRunBefore = persistenceService.hasRunBefore ?? false
        if hasRunBefore == false {
            UserDefaults.standard.setValue(true, forKey: InternalConfig.Storage.hasRunBefore)

            clear()
        }
    }

    func isValidSession() -> Bool {
        GigyaLogger.log(with: self, message: "[isValidSession]: start")

        if sessionLoad == false && persistenceService.biometricAllow == false {
            semaphore.wait()
        }

        GigyaLogger.log(with: self, message: "[isValidSession]: finish")

        return session?.isValid() ?? false
    }
    
    func setSession(_ model: SessionInfoModel?) {
        guard
            let sessionInfo = model,
            let sessionToken = sessionInfo.sessionToken,
            let sessionSecret = sessionInfo.sessionSecret,
            let gsession = GigyaSession(sessionToken: sessionToken, secret: sessionSecret)
            else {
                GigyaLogger.log(with: self, message: "[setSession]: failure parsing data")
                return
        }

        let data = NSKeyedArchiver.archivedData(withRootObject: gsession)

        if self.session == nil {
            persistenceService.setBiometricEnable(to: false)
            persistenceService.setBiometricLocked(to: false)
        }

        removeFromKeychain { [weak self] in
            self?.keychainHelper.add(with: InternalConfig.Storage.keySession, data: data)  { [weak self] err in
                GigyaLogger.log(with: self, message: "[setSession]: \(err)")
            }
        }

        self.session = gsession
    }

    func getSession(completion: @escaping ((Bool) -> Void) = { _ in} ) {
        let done: (Bool) -> () = { [weak self] success in
            self?.revokeSemaphore()
            completion(success)
        }

        keychainHelper.get(object: GigyaSession.self, name: InternalConfig.Storage.keySession) { [weak self] (result) in
            guard let self = self else {
                done(false)
                return
            }

            switch result {
            case .success(let sessionObject):
                self.sessionLoad = true
                self.session = sessionObject

                done(true)
            case .error(let error):
                self.sessionLoad = true
                done(false)
                GigyaLogger.log(with: self, message: error.rawValue)
            }
        }
    }

    private func revokeSemaphore() {
        self.semaphore.signal()
    }

    func setSessionAs(biometric: Bool, completion: @escaping (GigyaBiometricResult) -> Void) {
        guard let session = session else { return }

        let data = NSKeyedArchiver.archivedData(withRootObject: session)

        var mode: KeychainMode = .regular

        if biometric == true {
            mode = .biometric
        }

        keychainHelper.delete(name: InternalConfig.Storage.keySession) { [weak self] (result) in
            switch result {
            case .success:
                self?.keychainHelper.add(with: InternalConfig.Storage.keySession, data: data, state: mode) { [weak self] (result) in
                    switch result {
                    case .success:
                        completion(.success)
                    case .error(let error):
                        GigyaLogger.log(with: self, message: "can't using session with biometric - error: \(error.rawValue)")

                        completion(.failure)
                    }
                }
            case .error:
                completion(.failure)
            }
        }
    }

    func clear() {
        GigyaLogger.log(with: self, message: "[logout]")

        // remove session from Keychain
        removeFromKeychain()

        clearSession()
    }

    func clearSession() {
        GigyaLogger.log(with: self, message: "[clear session from dump]")

        // clear account from cach
        accountService.clear()

        // clear session from memory
        session = nil
    }

    private func removeFromKeychain(completion: @escaping () -> Void = {}) {
        keychainHelper.delete(name: InternalConfig.Storage.keySession) { [weak self] (result) in
            switch result {
            case .success(let data):
                GigyaLogger.log(with: self, message: "Session remove from keyChain - data: \(data ?? Data())")
            case .error(let error):
                GigyaLogger.log(with: self, message: "Problem with removing session from keyChain - error: \(error.rawValue)")
            }

            completion()
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "[SessionService]: failed - data not found")
    }
}

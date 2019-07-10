//
//  SessionManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class SessionService: IOCSessionServiceProtocol {

    var accountService: IOCAccountServiceProtocol

    var session: GigyaSession?

    var config: GigyaConfig

    private var sessionLoad: Bool = false

    private let semaphore = DispatchSemaphore(value: 0)

    required init(config: GigyaConfig, accountService: IOCAccountServiceProtocol) {
        self.accountService = accountService
        self.config = config

        getSession(biometric: config.biometricAllow ?? false)
    }

    func isValidSession() -> Bool {
        GigyaLogger.log(with: self, message: "[isValidSession]: start")
        let biomatricAllow = true

        if sessionLoad == false && biomatricAllow == false {
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

        GSKeychainStorage.add(with: InternalConfig.Storage.keySession, data: data) {
            [weak self] err in
            self?.session = gsession
        }
    }

    func getSession(biometric: Bool = false, completion: @escaping ((Bool) -> Void) = { _ in}) {
        if biometric == true {
            return
        }
        
        GSKeychainStorage.get(name: InternalConfig.Storage.keySession) { [weak self] (result) in
            guard let self = self else {
                return
            }

            switch result {
            case .succses(let data):
                guard let session: GigyaSession = NSKeyedUnarchiver.unarchiveObject(with: data!) as? GigyaSession else {
                    return
                }
                self.sessionLoad = true
                self.session = session

                completion(true)
            case .error(let error):
                self.sessionLoad = true
                completion(false)
                GigyaLogger.log(with: self, message: error.rawValue)
            }

            self.semaphore.signal()
        }
    }

    func setSessionAs(biometric: Bool, completion: @escaping (GigyaBiometricResult) -> Void) {
        guard let session = session else { return }

        let data = NSKeyedArchiver.archivedData(withRootObject: session)

        var mode: KeychainMode = .regular

        if biometric == true {
            mode = .biometric
        }

        GSKeychainStorage.delete(name: InternalConfig.Storage.keySession) { (result) in
            switch result {
            case .succses:
                GSKeychainStorage.add(with: InternalConfig.Storage.keySession, data: data, state: mode) { [weak self] (result) in
                    switch result {
                    case .succses:
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

    private func removeFromKeychain() {
        GSKeychainStorage.delete(name: InternalConfig.Storage.keySession) { [weak self] (result) in
            switch result {
            case .succses(let data):
                GigyaLogger.log(with: self, message: "Session saved in the keyChain - data: \(data ?? Data())")
            case .error(let error):
                GigyaLogger.log(with: self, message: "Problem with saveing session in the keyChain - error: \(error.rawValue)")
            }
        }
    }

}

//
//  SessionManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import UIKit

class SessionService: SessionServiceProtocol {

    var accountService: AccountServiceProtocol

    let keychainHelper: KeychainStorageFactory

    var session: GigyaSession?

    let config: GigyaConfig

    let persistenceService: PersistenceService

    private var sessionLoad: Bool = false

    private let semaphore = DispatchSemaphore(value: 0)

    private lazy var sessionExpirationTimestamp: Double = {
        // TODO: move expirationSession to GigyaSession
        return persistenceService.expirationSession ?? 0
    }()

    private var sessionLifeCountdownTimer: Timer?

    init(config: GigyaConfig, persistenceService: PersistenceService, accountService: AccountServiceProtocol, keychainHelper: KeychainStorageFactory) {
        self.accountService = accountService
        self.keychainHelper = keychainHelper
        self.config = config
        self.persistenceService = persistenceService

        checkFirstRun()

        getSession(skipLoadSession: persistenceService.biometricAllow ?? false)
    }

    private func registerAppStateEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appReturnToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    private func unregisterAppStateEvents() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func appMovedToBackground() {
        sessionLifeCountdownTimer?.invalidate()
    }

    @objc func appReturnToForeground() {
        startSessionCountdownTimerIfNeeded()
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

        if sessionExpirationTimestamp > 0, Date().timeIntervalSince1970 > sessionExpirationTimestamp {
            return false
        }

        if sessionLoad == false && persistenceService.biometricAllow == false {
            semaphore.wait()
        }

        GigyaLogger.log(with: self, message: "[isValidSession]: finish")

        return session?.isValid() ?? false
    }
    
    func setSession(_ sessionInfo: SessionInfoModel?) {
        guard
            let sessionInfo = sessionInfo,
            let sessionToken = sessionInfo.sessionToken,
            let sessionSecret = sessionInfo.sessionSecret,
            let gsession = GigyaSession(sessionToken: sessionToken, secret: sessionSecret)
            else {
                GigyaLogger.log(with: self, message: "[setSession]: failure parsing data")
                return
        }

        let data = NSKeyedArchiver.archivedData(withRootObject: gsession)

        if self.session == nil {
            // When session not in the heap, need to remove the session from keyChain. (with biometric can't override the session after client called OptOut)
            removeFromKeychain { [weak self] in
                self?.keychainHelper.add(with: InternalConfig.Storage.keySession, data: data) { err in }
            }

            persistenceService.setBiometricEnable(to: false)
            persistenceService.setBiometricLocked(to: false)
        } else {
            keychainHelper.add(with: InternalConfig.Storage.keySession, data: data) { err in }
        }

        self.session = gsession

        // Check session expiration.
        if let sessionExpiration = Double(sessionInfo.sessionExpiration ?? "0"), sessionExpiration > 0 {
            sessionExpirationTimestamp = Date().timeIntervalSince1970 + sessionExpiration
            persistenceService.setExpirationSession(to: sessionExpirationTimestamp)
            startSessionCountdownTimerIfNeeded()
        }
    }

    func getSession(skipLoadSession: Bool = false, completion: @escaping ((Bool) -> Void) = { _ in}) {
        if skipLoadSession == true {
            return
        }
        
        keychainHelper.get(name: InternalConfig.Storage.keySession) { [weak self] (result) in
            guard let self = self else {
                return
            }

            switch result {
            case .succses(let data):
                guard let session: GigyaSession = NSKeyedUnarchiver.unarchiveObject(with: data!) as? GigyaSession else {
                    completion(false)
                    return
                }

                self.sessionLoad = true
                self.session = session

                self.refreshSessionExpiration()
                self.startSessionCountdownTimerIfNeeded()

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

        keychainHelper.delete(name: InternalConfig.Storage.keySession) { [weak self] (result) in
            switch result {
            case .succses:
                self?.keychainHelper.add(with: InternalConfig.Storage.keySession, data: data, state: mode) { [weak self] (result) in
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

    // MARK: - SESSION EXPIRATION

    func refreshSessionExpiration() {
        // Check if already passed. Reset if so.
        if sessionExpirationTimestamp > 0 && sessionExpirationTimestamp < Date().timeIntervalSince1970 {
            persistenceService.setExpirationSession(to: 0)
        }
    }

    func startSessionCountdownTimerIfNeeded() {
        guard let session = session else { return }

        if session.isValid() && sessionExpirationTimestamp > 0 {
            let currentTime = Date().timeIntervalSince1970
            let timeUntilSessionExpires = sessionExpirationTimestamp - currentTime

            GigyaLogger.log(with: self, message: "startSessionCountdownTimerIfNeeded: Session is set to expire in: \(timeUntilSessionExpires) start countdown timer")

            if timeUntilSessionExpires > 0 {
                // start session
                startSessionCountdown(futureTime: timeUntilSessionExpires)
                registerAppStateEvents()
            } else {
                NotificationCenter.default.post(name: .didGigyaSessionExpire, object: nil)
            }
        }
    }

    public func cancelSessionCountdownTimer() {
        GigyaLogger.log(with: self, message: "[startSessionCountdown] - Timer cancel")

        if let sessionLifeCountdownTimer = sessionLifeCountdownTimer {
            sessionLifeCountdownTimer.invalidate()
        }
    }

    private func startSessionCountdown(futureTime: Double) {
        GigyaLogger.log(with: self, message: "[startSessionCountdown] - Timer start")

        sessionLifeCountdownTimer = Timer.scheduledTimer(withTimeInterval: futureTime, repeats: false, block: { [weak self] (timer) in
            // cancel timer
            timer.invalidate()

            // clear timer from memory
            self?.sessionLifeCountdownTimer = nil

            // unregister events (foreground / background)
            self?.persistenceService.setExpirationSession(to: 0)
            self?.unregisterAppStateEvents()

            // Send notification broadcast 
            NotificationCenter.default.post(name: .didGigyaSessionExpire, object: nil)

            GigyaLogger.log(with: self, message: "[startSessionCountdown] - Timer finish")

        })

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
            case .succses(let data):
                GigyaLogger.log(with: self, message: "Session saved in the keyChain - data: \(data ?? Data())")
            case .error(let error):
                GigyaLogger.log(with: self, message: "Problem with saveing session in the keyChain - error: \(error.rawValue)")
            }

            completion()
        }
    }

}

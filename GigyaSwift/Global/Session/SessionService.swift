//
//  SessionManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class SessionService: SessionServiceProtocol {

    var accountService: AccountServiceProtocol

    let keychainHelper: KeychainStorageFactory

    var session: GigyaSession?

    let config: GigyaConfig

    let persistenceService: PersistenceService

    private var sessionLoad: Bool = false

    private let semaphore = DispatchSemaphore(value: 0)

    private var sessionLifeCountdownTimer: Timer?

    var handlersAfterSetSession: InterceptorsUtils = InterceptorsUtils()

    private var registerAppState: Bool = false

    // allow to enable/disable clear cookies from webKit in logout
    private var clearCookiesEnable = true

    init(config: GigyaConfig, persistenceService: PersistenceService, accountService: AccountServiceProtocol, keychainHelper: KeychainStorageFactory) {
        self.accountService = accountService
        self.keychainHelper = keychainHelper
        self.config = config
        self.persistenceService = persistenceService

        checkFirstRun { [weak self] in
            if self?.persistenceService.biometricAllow == false {
                self?.getSession() { [weak self] success in
                    GigyaLogger.log(with: self, message: "[SessionService.getFromInit]: is success: - \(success)")
                }
            }
        }
    }

    private func registerAppStateEvents() {
        if registerAppState == false {
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appReturnToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            registerAppState = true
        }
    }

    private func unregisterAppStateEvents() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        registerAppState = false
    }

    @objc func appMovedToBackground() {
        sessionLifeCountdownTimer?.invalidate()

        GigyaLogger.log(with: self, message: "stop: app going to backgroud")
    }

    @objc func appReturnToForeground() {
        startSessionCountdownTimerIfNeeded()
    }

    func checkFirstRun(completion: @escaping () -> Void) {
        let hasRunBefore = persistenceService.hasRunBefore ?? false
        if hasRunBefore == false {
            UserDefaults.standard.setValue(true, forKey: InternalConfig.Storage.hasRunBefore)

            clear(completion: completion)

            GigyaLogger.log(with: self, message: "hasRunBefore: clear session")
        } else {
            completion()
        }
    }

    func isValidSession() -> Bool {
        GigyaLogger.log(with: self, message: "[isValidSession]: start")

        if sessionLoad == false && persistenceService.biometricAllow == false {
            semaphore.wait()
        }

        GigyaLogger.log(with: self, message: "[isValidSession]: finish - result: \(String(describing: self.session?.isValid()))")

        return self.session?.isValid() ?? false
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

        session = gsession

        handlersAfterSetSession.runAll()

        removeFromKeychain { [weak self] in
            if let sessionExpiration = Double(sessionInfo.sessionExpiration ?? "0"), sessionExpiration > 0 {
                let sessionExpirationTimestamp = Date().timeIntervalSince1970 + sessionExpiration
                gsession.sessionExpirationTimestamp = sessionExpirationTimestamp
            }

            let data = NSKeyedArchiver.archivedData(withRootObject: gsession)

            self?.keychainHelper.add(with: InternalConfig.Storage.keySession, data: data)  { [weak self] err in
                GigyaLogger.log(with: self, message: "[setSession]: \(err)")
            }

            if self?.session == nil {
                self?.persistenceService.setBiometricEnable(to: false)
                self?.persistenceService.setBiometricLocked(to: false)
            }

            self?.session = gsession

            // Check session expiration.
            if let sessionExpiration = self?.session?.sessionExpirationTimestamp, sessionExpiration > 0 {
                self?.startSessionCountdownTimerIfNeeded()
            }
        }
    }

    func getSession(completion: @escaping ((Bool) -> Void) = { _ in} ) {
        // closure to make tasks before call completion
        let didFinish: (Bool) -> () = { [weak self] success in
            self?.revokeSemaphore()
            completion(success)
        }

        keychainHelper.get(object: GigyaSession.self, name: InternalConfig.Storage.keySession) { [weak self] (result) in
            guard let self = self else {
                didFinish(false)
                return
            }

            switch result {
            case .success(let sessionObject):
                if sessionObject.isActive() == false {
                    didFinish(true)
                    return
                }

                self.sessionLoad = true
                self.session = sessionObject

                GigyaLogger.log(with: self, message: "session load to dump")

                self.startSessionCountdownTimerIfNeeded()
                didFinish(true)
            case .error(let error):
                self.sessionLoad = true
                didFinish(false)
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

    // MARK: - SESSION EXPIRATION

    private func expireSession() {
        clear()

        print("expired")
        NotificationCenter.default.post(name: .didGigyaSessionExpire, object: nil)
    }

    func startSessionCountdownTimerIfNeeded() {
        guard let session = session else { return }

        if !session.isValid() {
            expireSession()
        } else {
            let sessionExpiration = session.sessionExpirationTimestamp ?? 0
            let currentTime = Date().timeIntervalSince1970
            let timeUntilSessionExpires = sessionExpiration - currentTime

            GigyaLogger.log(with: self, message: "startSessionCountdownTimerIfNeeded: Session is set to expire in: \(timeUntilSessionExpires) start countdown timer")

            if timeUntilSessionExpires > 0 {
                // start session
                startSessionCountdown(futureTime: timeUntilSessionExpires)
                registerAppStateEvents()
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


        DispatchQueue.main.async { [weak self] in
            self?.sessionLifeCountdownTimer = Timer.scheduledTimer(withTimeInterval: futureTime,
                                                                   repeats: false,
                                                                   block: { [weak self] (timer) in
                // cancel timer
                timer.invalidate()

                // clear timer from memory
                self?.sessionLifeCountdownTimer = nil

                // unregister events (foreground / background)
                self?.persistenceService.setExpirationSession(to: 0)
                self?.unregisterAppStateEvents()

                // call to check session expirtation (remove session and send broadcast)
                if let session = self?.session, !session.isValid() {
                    self?.expireSession()
                }

                GigyaLogger.log(with: self, message: "[startSessionCountdown] - Timer finish")

            })
        }
    }

    func clear() {
        clear { }
    }

    func clear(completion: @escaping () -> Void) {
        GigyaLogger.log(with: self, message: "[logout]")

        // remove session from Keychain
        removeFromKeychain {
            completion()
        }

        clearSession()
    }

    func clearSession() {
        GigyaLogger.log(with: self, message: "[clear session from dump]")

        // clear account from cach
        accountService.clear()

        // clear all cookies created in WKWebView
        clearCookies()

        // clear session from memory
        self.session = nil
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

    private func clearCookies() {
        if clearCookiesEnable {
            DispatchQueue.main.async {
                HTTPCookieStorage.shared.removeCookies(since: .distantPast)

                WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    records.forEach { record in
                        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                        GigyaLogger.log(with: self, message: "Cookie ::: \(record) deleted")
                    }
                }
            }
        }
    }

    public func setClearCookies(to value: Bool) {
        clearCookiesEnable = value
    }

    deinit {
        GigyaLogger.log(with: self, message: "[SessionService]: failed - data not found")
    }
}

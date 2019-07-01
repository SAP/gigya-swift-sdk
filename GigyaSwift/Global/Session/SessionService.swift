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

    var sessionLoad = false

    private let semaphore = DispatchSemaphore(value: 0)

    required init(config: GigyaConfig, accountService: IOCAccountServiceProtocol) {
        self.accountService = accountService
        self.config = config

        getSession()
    }

    func isValidSession() -> Bool {
//        GigyaLogger.log(with: self, message: "[isValidSession]: \(gigyaApi.isValidSession())")

        if sessionLoad == false {
            semaphore.wait()
        }

        return session?.isValid() ?? false
    }
    
    func setSession(_ model: SessionInfoModel?) {
        guard let sessionInfo = model else {
            return
        }

        let gsession = GigyaSession(sessionToken: sessionInfo.sessionToken, secret: sessionInfo.sessionSecret)
        let data = NSKeyedArchiver.archivedData(withRootObject: gsession)

        GSKeychainStorage.add(with: InternalConfig.Storage.keySession, data: data) {
            [weak self] err in
            self?.session = gsession
        }
    }

    func getSession() {
//        gigyaApi.getSession { [weak self] (session) in
//            self?.session = session
//            result(session)
//        }
            GSKeychainStorage.get(name: InternalConfig.Storage.keySession) { [weak self] (result) in
                switch result {
                case .succses(let data):
                    let session: GigyaSession = NSKeyedUnarchiver.unarchiveObject(with: data!) as! GigyaSession
                    self?.sessionLoad = true
                    self?.session = session
                    self?.semaphore.signal()
                case .error(let error):
                    self?.sessionLoad = true
                    self?.semaphore.signal()
                    break
                }
                //            let session = NSKeyedUnarchiver.unarchiveObject(with: result)
            }

    }

    func clear() {
        GigyaLogger.log(with: self, message: "[logout]")

        accountService.clear()
        removeFromKeychain()
        session = nil

    }

    private func removeFromKeychain() {
        GSKeychainStorage.delete(name: InternalConfig.Storage.keySession) { (result) in
            
        }
    }
}

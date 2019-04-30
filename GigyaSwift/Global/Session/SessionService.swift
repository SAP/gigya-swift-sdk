//
//  SessionManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class SessionService: IOCSessionServiceProtocol {

    var gigyaApi: IOCGigyaWrapperProtocol
    var session: GigyaSession?

    required init(gigyaApi: IOCGigyaWrapperProtocol) {
        self.gigyaApi = gigyaApi
    }

    func isValidSession() -> Bool {
        return gigyaApi.isValidSession()
    }

    func setSession(_ session: GigyaSession) {
        gigyaApi.setSession(session)
    }

    func getSession(result: @escaping (GigyaSession?) -> Void) {
        gigyaApi.getSession { [weak self] (session) in
            self?.session = session
            result(session)
        }
    }

    func clear() {
        gigyaApi.logout()
    }
}

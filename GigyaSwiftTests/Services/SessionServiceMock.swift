//
//  SessionServiceMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 25/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import Gigya

class SessionServiceMock: SessionServiceProtocol {
    var session: GigyaSession?

    func isValidSession() -> Bool {
        return true
    }

    func setSession(_ model: SessionInfoModel?) {

    }

    func getSession(completion: @escaping ((Bool) -> Void)) {
        completion(true)
    }

    func setSessionAs(biometric: Bool, completion: @escaping (GigyaBiometricResult) -> Void) {
        completion(.success)
    }

    func clear() {

    }

    func clear(completion: @escaping () -> Void) {
        completion()
    }

    func clearSession() {

    }


}

//
//  OtpProtocol.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 04/02/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Foundation
import Gigya

protocol OtpProtocol {
    func isAvailable() -> Bool

    func login<T: GigyaAccountProtocol>(obj: T.Type, phone: String, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void)

    func validate(code: String)
}

extension OtpProtocol {
    func isAvailable() -> Bool {
        return false
    }

    func login<T: GigyaAccountProtocol>(obj: T.Type, phone: String, params: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        // Stud
    }

    func validate(code: String) {
        
    }
}

open class OtpHead: OtpProtocol {
    var otpHelper: Any?
}


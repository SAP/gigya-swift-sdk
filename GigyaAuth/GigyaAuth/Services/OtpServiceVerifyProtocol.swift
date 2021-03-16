//
//  OtpServiceVerifyProtocol.swift
//  GigyaAuth
//
//  Created by Shmuel, Sagi on 10/02/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Foundation

public protocol OtpServiceVerifyProtocol {
    var vToken: String? { get }
    var data: [String: Any]? { get }

    /**
     This method is used to log in users via Phone Number Login. It requires the vToken and code returned from accounts.OTP.sendCode.

     - Parameter code:   OTP code.
     */

    func verify(code: String)
}

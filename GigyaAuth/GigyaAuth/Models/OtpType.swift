//
//  OtpType.swift
//  GigyaAuth
//
//  Created by Shmuel, Sagi on 10/02/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Foundation

enum OtpType {
    case login, update

    func getApi() -> String {
        switch self {
        case .login:
            return "accounts.otp.login"
        case .update:
            return "accounts.otp.update"
        }
    }
}
